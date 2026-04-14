# ADR-0003: Public Network Posture — No Private Endpoints for Dev/Demo (Provisional)

![Step](https://img.shields.io/badge/Step-3-blue?style=for-the-badge)
![Status](https://img.shields.io/badge/Status-Provisional-orange?style=for-the-badge)
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

> Status: **Provisional** — must be revalidated after Step 3.5 Governance Discovery
> Date: 2026-04-14
> Deciders: Architecture Agent (malta-catering project)
> See also: ARC-004 in `02-architecture-assessment.md`

## 🔍 Context

The Malta Catering portal uses three data-plane Azure services that support private
endpoint connectivity: **Azure Storage Account**, **Azure Key Vault**, and the
**Container Apps Environment**. Private endpoints would:

- Route traffic between Container Apps and Storage/Key Vault through the Azure
  backbone (no public internet traversal)
- Disable public network access on Storage and Key Vault, reducing attack surface
- Require a VNet, private DNS zones, and VNet integration for Container Apps

Additional cost for full private endpoint configuration:
- VNet: free
- Private Endpoint for Storage: ~$7.30/month
- Private Endpoint for Key Vault: ~$7.30/month
- Container Apps VNet integration: requires Dedicated plan (~$50+/mo minimum)

Total additional cost if all PEs implemented: **+$64.60/month minimum** — a
**263% cost increase** over the baseline ~$24.53/month.

Governance-level Azure Policies (Step 3.5) may mandate private endpoints for
certain resource types (e.g., `require-private-endpoint-storage` or
`deny-public-access-storage`). This ADR documents the conscious dev/demo trade-off
and the production upgrade path.

## ✅ Decision

**ARC-004**: For this dev/demo environment, accept **public network access** on all
services. No private endpoints, no VNet integration, no WAF.

- Storage Account: public network access enabled (with Managed Identity auth)
- Key Vault: public network access enabled (with RBAC + Managed Identity)
- Container Apps: public ingress endpoint (managed TLS)
- No Azure WAF or DDoS Standard protection

**This decision is provisional**. It must be reviewed after Step 3.5 Governance
Discovery confirms or denies any subscription-level Azure Policy mandating
private endpoints or blocking public access.

## 🔄 Alternatives Considered

| Option                             | Pros                                              | Cons                                                    | WAF Impact                               |
| ---------------------------------- | ------------------------------------------------- | ------------------------------------------------------- | ---------------------------------------- |
| **Public endpoints (selected)**    | Zero additional cost; simple config               | Larger attack surface; blocked by strict governance     | Cost: ↑↑, Security: ↓                   |
| PE for Storage + KV (CA Consumption) | Secures data plane traffic                      | +$14.60/mo; CA Consumption cannot join VNet natively    | Cost: →, Security: ↑, Operations: ↓     |
| Full PE + CA Dedicated plan        | Gold standard network isolation                   | +$64.60/mo minimum (263% increase)                      | Cost: ↓↓, Security: ↑↑, Operations: ↓  |
| Service Endpoints (Storage + KV)   | Near-zero cost; scopes access to VNet             | Requires CA VNet integration; limited to same-region    | Cost: →, Security: ↑, Operations: →     |
| Azure Firewall + SNAT              | Full egress control                               | ~$140/mo for Firewall Standard; overkill for demo       | Cost: ↓↓↓, Security: ↑↑                 |

## ⚖️ Consequences

### Positive

- No additional networking cost — keeps total at ~$24.53/month
- No VNet or Private DNS Zone complexity to manage
- Container Apps Consumption plan retains scale-to-zero behavior (Dedicated plan
  cannot scale to zero)
- Simpler Bicep templates — no PE, DNS zone, or VNet integration modules needed

### Negative

- Storage Account and Key Vault are reachable from public internet (Managed
  Identity auth still required — no anonymous access possible)
- WAF/DDoS Standard protection absent — low-traffic demo does not justify cost,
  but a targeted attack could cause brief unavailability
- If governance mandates private endpoints: architecture requires significant
  rework — VNet, Dedicated plan, PE modules, private DNS zones

### Neutral

- Managed Identity authentication provides strong access control independent
  of network posture — a misconfigured network doesn't grant access to data

## 🏛️ WAF Pillar Analysis

| Pillar      | Impact | Notes                                                                               |
| ----------- | ------ | ----------------------------------------------------------------------------------- |
| Security    | ↓      | Public endpoints increase attack surface; MI auth mitigates data access risk        |
| Reliability | →      | Network topology change has no reliability impact; public endpoints are more robust  |
| Performance | ↑      | No VNet traversal latency; direct Azure backbone routing between services            |
| Cost        | ↑↑     | Avoids ~$64.60/mo for full private endpoint architecture                             |
| Operations  | ↑      | No VNet, DNS zone, or PE resources to manage; simpler incident response              |

## 🔒 Compliance Considerations

- **GDPR**: Public endpoints do not violate GDPR as long as data is encrypted
  in transit (TLS 1.2, enforced) and access is authenticated (Managed Identity)
- **Azure Policy**: Some enterprise tenants enforce `deny-public-network-access`
  on Key Vault and Storage — this ADR will be superseded if such policies exist
  in the target subscription (check in Step 3.5 Governance Discovery)
- **PCI DSS**: Not in scope for this project (cash-on-delivery payment model)
- **SOC 2 / ISO 27001**: Not required for dev/demo; production certification
  would require private endpoints and network segmentation

## 📝 Implementation Notes

- This ADR is **provisional** — revalidate after Step 3.5 Governance Discovery
- If governance mandates private endpoints, the fallback architecture is:
  1. Upgrade Container Apps to Dedicated workload profile (for VNet integration)
  2. Create VNet in `swedencentral` with 2 subnets (CA, PE)
  3. Add Private Endpoint for Storage Account (`blob`, `table` sub-resources)
  4. Add Private Endpoint for Key Vault (`vault` sub-resource)
  5. Deploy Private DNS Zones (`privatelink.blob.core.windows.net`,
     `privatelink.table.core.windows.net`, `privatelink.vaultcore.azure.net`)
  6. Total additional cost: ~$64.60/month
- For production (governance-permitting public endpoints): add Azure Front Door
  Standard with WAF policy (~$36/mo) before go-live to protect Container Apps
  public ingress

---

<div align="center">

> Generated by design agent | 2026-04-14

| ⬅️ Previous                                                                         | 📑 Index            | Next ➡️             |
| ----------------------------------------------------------------------------------- | ------------------- | ------------------- |
| [03-des-adr-0002-table-storage-persistence.md](03-des-adr-0002-table-storage-persistence.md) | [README](README.md) | [README](README.md) |

</div>
