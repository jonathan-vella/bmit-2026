# ADR-0002: Azure Table Storage for Order Persistence with Accepted Data Loss

![Step](https://img.shields.io/badge/Step-3-blue?style=for-the-badge)
![Status](https://img.shields.io/badge/Status-Accepted-brightgreen?style=for-the-badge)
![Type](https://img.shields.io/badge/Type-ADR-purple?style=for-the-badge)

<details open>
<summary><strong>📑 Decision Contents</strong></summary>

- [🔍 Context](#-context)
- [✅ Decision](#-decision)
- [🔄 Alternatives Considered](#-alternatives-considered)
- [⚖️ Consequences](#%EF%B8%8F-consequences)
- [🏛️ WAF Pillar Analysis](#%EF%B8%8F-waf-pillar-analysis)
- [🔒 Compliance Considerations](#-compliance-considerations)
- [📝 Implementation Notes](#-implementation-notes)

</details>

> Status: Accepted
> Date: 2026-04-14
> Deciders: Architecture Agent (malta-catering project)
> Supersedes: ARC-001 open finding from Step 1 requirements review

## 🔍 Context

The Malta Catering portal requires persistent storage for:

1. **Customer orders** — items ordered, timestamp, customer reference, status
2. **Menu items** — available pastizzi, Cisk, Kinnie with prices
3. **GDPR compliance** — customer profile data must be erasable (right-to-erasure)

Budget constraint: storage must cost under ~$10/month. Traffic: 1 TPS, up to 20
orders/hour at peak. Relational joins are not required — orders are simple
key-value lookups by customer or date. A Step 1 challenger review flagged that
Table Storage lacks native backup (REQ-001).

The RPO from requirements is 12 hours — however, this is a dev/demo environment
with explicitly relaxed reliability expectations.

## ✅ Decision

Use **Azure Table Storage (Standard LRS)** as the persistence layer, with:

- **ARC-001 accepted**: For this dev/demo environment, application-level data loss
  is explicitly accepted. The 12h RPO is **relaxed to best-effort** for the demo.
- **ARC-003 GDPR pattern**: PII and order facts are stored in separate partition
  keys to support right-to-erasure without destroying order records.

**Table design:**

| Partition Key      | Row Key       | Contains PII | Erasure Action                  |
| ------------------ | ------------- | ------------ | ------------------------------- |
| `customer_{id}`    | `profile`     | Yes          | Delete entire entity            |
| `order_{date}`     | `{orderId}`   | No (anon.)   | Retain; `customer_id` → SHA-256 |
| `menu_{category}`  | `{itemId}`    | No           | Retain indefinitely             |

On erasure request: delete `customer_*` partition, replace `customer_id` field
in all order entities with a one-way SHA-256 hash. Menu table never holds PII.

## 🔄 Alternatives Considered

| Option                        | Pros                                                  | Cons                                                      | WAF Impact                              |
| ----------------------------- | ----------------------------------------------------- | --------------------------------------------------------- | --------------------------------------- |
| **Table Storage (LRS)**       | $0.0184/GB/mo, 20K TPS, simple API, Managed Identity | No native backup, no multi-region, no advanced querying   | Cost: ↑↑, Reliability: ↓               |
| Azure Cosmos DB (Serverless)  | Native backup, global distribution, rich querying     | Min ~$24/mo additional; over-engineered for 1 TPS         | Cost: ↓, Reliability: ↑↑               |
| Azure SQL (Free tier)         | Relational, backup included, familiar tooling         | 32 GiB / 100K DTU/month then paid; overkill for key-value | Cost: ↔, Operations: ↓                 |
| Azure Blob Storage (JSON)     | Very cheap, simple                                    | No indexing; querying requires full scan                  | Cost: ↑, Performance: ↓↓               |
| Table Storage + daily export  | Adds native backup via scheduled Function App         | ~$1-2/mo extra; adds operational complexity               | Cost: →, Reliability: ↑ (prod path)   |

## ⚖️ Consequences

### Positive

- Storage Account (Table + Blob) costs ~$8.47/month — extremely low
- Table Storage provides 20,000 entities/second — 1 TPS is negligible
- LRS provides 11 nines durability against hardware failure
- Managed Identity access eliminates connection string exposure
- Single Storage Account serves both Table (orders/menu) and Blob (future use)

### Negative

- **ARC-001**: No automated backup — accidental deletion or app-level corruption
  is unrecoverable without manual intervention. Accepted for demo.
- No analytical query support — order reporting requires full-partition scans
- No native TTL/expiry on entities — expired orders require manual cleanup logic

### Neutral

- The architecture includes a documented production upgrade path:
  add a daily Azure Functions timer trigger to export Table Storage to Blob
  as JSON snapshots (~$1-2/mo additional cost, to be implemented before prod)

## 🏛️ WAF Pillar Analysis

| Pillar      | Impact | Notes                                                                          |
| ----------- | ------ | ------------------------------------------------------------------------------ |
| Security    | ↑      | Managed Identity access; no connection string in app config; LRS encryption    |
| Reliability | ↓      | No backup for demo; ARC-001 accepted; LRS protects hardware failure only       |
| Performance | ↑      | 20K TPS capacity vs 1 TPS demand; table design matches query patterns          |
| Cost        | ↑↑     | $8.47/mo for full storage account — best available for this workload profile   |
| Operations  | →      | Standard LRS requires no replication config; erasure pattern adds mild complexity |

## 🔒 Compliance Considerations

- **GDPR Right-to-Erasure (ARC-003)**: PII/order separation ensures customer
  profile deletion does not destroy order records or business audit trail
- **Data residency**: LRS stores all 3 copies within `swedencentral` — EU-only,
  no cross-region replication, satisfies GDPR geographic constraint
- **Encryption**: Azure Storage encrypts data at rest with platform-managed keys
  by default — no additional BYOK configuration required for dev/demo
- **Social IdP**: Customer identity tokens are processed by the external IdP
  (Google/Microsoft); only the derived `customer_id` value enters Table Storage

## 📝 Implementation Notes

- Partition key design must be implemented as specified in the table above
- Application must hash `customer_id` with SHA-256 before writing to order entities
  (hash input: `customer_id + app_secret_salt` to prevent rainbow table attacks)
- Erasure endpoint (`DELETE /api/customer/{id}`) must:
  1. Delete `customer_{id}` partition
  2. Query all `order_*` partitions for matching `customer_id`
  3. Replace with `SHA256(customer_id + salt)`
  4. Log erasure event to Application Insights (without PII)
- **Production path before go-live**: Add daily timer-trigger Azure Function to
  export Table Storage entities to Blob Storage as timestamped JSON snapshots

---

<div align="center">

> Generated by design agent | 2026-04-14

| ⬅️ Previous                                                                               | 📑 Index            | Next ➡️                                                                      |
| ----------------------------------------------------------------------------------------- | ------------------- | ---------------------------------------------------------------------------- |
| [03-des-adr-0001-container-apps-consumption-compute.md](03-des-adr-0001-container-apps-consumption-compute.md) | [README](README.md) | [03-des-adr-0003-public-network-posture.md](03-des-adr-0003-public-network-posture.md) |

</div>
