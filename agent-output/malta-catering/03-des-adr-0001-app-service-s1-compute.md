# ADR-0001: App Service S1 (Linux Containers) as Compute Platform

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

> Status: Accepted (Revised 2026-04-15 — replaces original ACA Consumption decision)
> Date: 2026-04-15
> Deciders: Architecture Agent (malta-catering project)

## 🔍 Context

The Malta Catering ordering portal needs a compute platform to host a containerized
React SPA with a lightweight API for pastizzi/Cisk/Kinnie orders. Requirements:

- **Budget**: EUR 100–500/month (soft cap)
- **Traffic**: 1 TPS sustained, up to 1,000 concurrent users at lunch-rush peaks
- **Operations**: Minimal ops overhead — managed TLS, no dedicated infra to manage
- **Deployment**: Containerized workload (single Docker image) via Azure Container Registry
- **Region**: `swedencentral` for GDPR EU data residency

The original decision selected Azure Container Apps (Consumption plan). However,
deployment was blocked by a **regional capacity error**
(`ManagedEnvironmentCapacityHeavyUsageError` in `swedencentral`) preventing creation
of the Container Apps Environment. Combined with a strategic preference for App Service
as a more familiar, always-on PaaS platform with native staging slot support, the
team decided to switch to Azure App Service S1 (Linux) with container deployment
from ACR Premium.

The architecture must be simple enough for a demo/dev environment while retaining
a clear production upgrade path.

## ✅ Decision

Use **Azure App Service S1 (Linux) with containers deployed from ACR Premium** to
host both the React SPA and API within a single containerized application.

### Configuration

| Setting             | Value                              |
| ------------------- | ---------------------------------- |
| SKU                 | S1 (Standard)                      |
| OS                  | Linux (reserved)                   |
| Container source    | ACR Premium (private endpoint)     |
| VNet Integration    | `snet-app-service` (`10.0.0.0/27`) |
| Staging Slot        | Enabled (blue-green deployments)   |
| Always-on           | `true`                             |
| Managed Identity    | System-assigned, enabled           |
| HTTPS only          | `true`                             |
| HTTP/2              | Enabled                            |
| TLS minimum version | 1.2                                |
| FTPS                | Disabled                           |

## 🔄 Alternatives Considered

| Option                             | Pros                                                      | Cons                                                                                                                                             | WAF Impact                               |
| ---------------------------------- | --------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------ | ---------------------------------------- |
| **App Service S1 (Linux)**         | Always-on, staging slots, VNet integration, familiar PaaS | ~$73/mo base cost, no scale-to-zero                                                                                                              | Cost: →, Operations: ↑, Performance: ↑   |
| Container Apps Consumption         | Scale-to-zero, ~$10.76/mo, managed TLS                    | **Rejected** — regional capacity blocker (`ManagedEnvironmentCapacityHeavyUsageError` in `swedencentral`) + strategic preference for App Service | Cost: ↑↑, Operations: ↑, Performance: ↓  |
| Container Apps Dedicated           | No cold starts, higher throughput                         | **Rejected** — same regional capacity issues as Consumption; ~$50+/mo baseline                                                                   | Cost: ↓↓, Performance: ↑, Reliability: ↑ |
| Azure App Service (Free/B1)        | Familiar, always-on, CI/CD via deployment slots           | B1 ~$13/mo, limited compute; Free tier no container support                                                                                      | Cost: ↓, Operations: →, Performance: ↑   |
| Azure Functions (Flex Consumption) | True per-invocation billing, great for API                | SPA hosting requires separate service; more complex                                                                                              | Cost: ↑, Operations: ↓, Performance: →   |
| AKS (smallest node pool)           | Full orchestration, multi-service                         | Complex, ~$72/mo minimum for 1 node; no scale-to-zero                                                                                            | Cost: ↓↓↓, Operations: ↓↓                |

## ⚖️ Consequences

### Positive

- **No cold start** — always-on eliminates scale-from-zero latency entirely
- **Staging slot** — blue-green deployments with zero-downtime swap
- **VNet integration** — native support via `snet-app-service` subnet
- **Private endpoint capable** — ACR Premium with PE for secure image pulls
- **Familiar PaaS** — Easy Auth, Kudu console, well-documented platform
- Managed Identity natively supported — no secrets in environment variables
- Resolves the ACA regional capacity blocker (`ManagedEnvironmentCapacityHeavyUsageError`)

### Negative

- Higher base cost (~$73/mo vs ~$10.76/mo for ACA Consumption)
- No scale-to-zero — S1 App Service Plan is always running
- Single container model couples SPA and API — a future split requires separate App Services

### Neutral

- Same managed identity pattern as the original ACA decision
- Same container deployment model (ACR → App Service instead of ACR → Container Apps)

## 🏛️ WAF Pillar Analysis

| Pillar      | Score | Impact | Notes                                                                     |
| ----------- | ----- | ------ | ------------------------------------------------------------------------- |
| Security    | 8     | ↑      | Managed Identity + TLS 1.2 + VNet integration + ACR private endpoint      |
| Reliability | 7     | ↑      | 99.95% SLA, always-on (no cold start), staging slots for safe deployments |
| Performance | 9     | ↑↑     | Always-on eliminates cold start; 1 TPS well within S1 capacity            |
| Cost        | 7     | →      | ~$73/mo base cost — higher than ACA but within EUR 100–500 budget         |
| Operations  | 7     | ↑      | Managed TLS, Kudu console, Easy Auth, staging slot, familiar platform     |

## 🔒 Compliance Considerations

- Container Apps deploys within `swedencentral` Azure region — EU data residency satisfied
- Managed Identity eliminates credential storage, reducing GDPR data minimization risk
- No customer PII stored in container runtime environment — orders go to Table Storage
- Platform-managed encryption at rest for container runtime; no additional config needed

## 📝 Implementation Notes

- Container image should be built multi-arch (`linux/amd64`) for ACR compatibility
- Set `WEBSITES_PORT` / `PORT` environment variable for the container port
- Application Insights connection string should be sourced from Key Vault reference
- Use staging slot for blue-green deployments; swap to production after validation
- App Service Plan: `S1` (Standard), Linux reserved, single instance
- Estimated monthly cost: **~$73/mo** for App Service Plan S1
- ACR Premium with private endpoint for secure image pulls
- VNet integration on `snet-app-service` (`10.0.0.0/27`) subnet

---

<div align="center">

> Generated by design agent | 2026-04-15 (revised)

| ⬅️ Previous                                                    | 📑 Index            | Next ➡️                                                                                      |
| -------------------------------------------------------------- | ------------------- | -------------------------------------------------------------------------------------------- |
| [02-architecture-assessment.md](02-architecture-assessment.md) | [README](README.md) | [03-des-adr-0002-table-storage-persistence.md](03-des-adr-0002-table-storage-persistence.md) |

</div>
