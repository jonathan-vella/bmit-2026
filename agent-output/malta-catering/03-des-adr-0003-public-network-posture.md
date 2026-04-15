# ADR-0003: VNet Integration with Private Endpoints for Dev Environment

![Step](https://img.shields.io/badge/Step-3-blue?style=for-the-badge)
![Status](https://img.shields.io/badge/Status-Accepted-green?style=for-the-badge)
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

> Status: **Accepted (Revised 2026-04-15 — replaces original public-endpoint posture)**
> Date: 2026-04-15
> Deciders: Architecture Agent (malta-catering project)
> See also: ARC-004 in `02-architecture-assessment.md`

## 🔍 Context

The Malta Catering portal uses three data-plane Azure services that support private
endpoint connectivity: **Azure Storage Account**, **Azure Key Vault**, and **Azure
Container Registry (ACR)**. The original ADR-0003 accepted public endpoints as a
provisional trade-off for the dev/demo environment.

The switch from Container Apps Consumption to **App Service S1** enables **native
VNet integration at no additional compute cost** — S1 supports regional VNet
integration via a delegated subnet. This eliminates the primary cost barrier
(Dedicated plan ~$50+/mo) that made private endpoints prohibitive under the
original architecture.

Private endpoints are now used for all backend services:

- Route traffic between App Service and Storage/Key Vault/ACR through the Azure
  backbone (no public internet traversal)
- Disable public network access on Storage, Key Vault, and ACR, reducing attack
  surface
- Private DNS zones provide name resolution for private endpoint FQDNs

Additional cost for VNet + private endpoint configuration:

- VNet: free
- 3 Private Endpoints (Storage, Key Vault, ACR): 3 × ~$7.20/mo = ~$21.60/mo
- 3 Private DNS Zones: 3 × $0.50/mo = ~$1.50/mo

Total additional networking cost: **~$23.10/month** — modest compared to the
original $64.60/mo estimate under Container Apps Dedicated.

## ✅ Decision

**ARC-004 resolved**: Migrate from public endpoints to **VNet integration with
private endpoints** for all backend services.

- **App Service S1** with VNet integration via delegated subnet
  (`snet-app-service`, `10.0.0.0/27`)
- **Private endpoints** for Key Vault, Storage Account (table), and ACR in
  `snet-private-endpoints` (`10.0.0.32/27`)
- **3 private DNS zones** linked to the VNet:
  - `privatelink.vaultcore.azure.net`
  - `privatelink.table.core.windows.net`
  - `privatelink.azurecr.io`
- **Public inbound** to App Service only (HTTPS via App Service default hostname)
- **All backend traffic** routed through VNet (`vnetRouteAllEnabled: true`)

## 🔄 Alternatives Considered

| Option                                    | Pros                                         | Cons                                                | WAF Impact                           |
| ----------------------------------------- | -------------------------------------------- | --------------------------------------------------- | ------------------------------------ |
| **VNet + PE for all backends (selected)** | Backend isolation; resolves ARC-004; ~$23/mo | Added VNet/DNS complexity                           | Cost: →, Security: ↑↑, Operations: ↓ |
| Public endpoints (original ADR-0003)      | Zero additional cost; simple config          | Larger attack surface; blocked by strict governance | Cost: ↑↑, Security: ↓                |
| Service Endpoints (Storage + KV)          | Near-zero cost; scopes access to VNet        | Does not cover ACR; limited to same-region          | Cost: →, Security: ↑, Operations: →  |
| Azure Firewall + SNAT                     | Full egress control                          | ~$140/mo for Firewall Standard; overkill for demo   | Cost: ↓↓↓, Security: ↑↑              |

## ⚖️ Consequences

### Positive

- Backend services (Storage, Key Vault, ACR) are **not exposed to the public
  internet** — accessible only via private endpoints within the VNet
- DNS resolution for backend services uses **private DNS zones**, ensuring
  traffic stays on the Azure backbone
- **ARC-004 risk (public endpoint exposure) is resolved** — no longer provisional
- Managed Identity authentication remains in place as a defense-in-depth layer

### Negative

- Added infrastructure complexity: VNet, 2 subnets, 3 private endpoints,
  3 private DNS zones — more Bicep modules to author and maintain
- Additional cost of **~$23.10/month** (3 PE + 3 DNS zones)
- Debugging connectivity issues requires understanding of VNet routing and
  private DNS resolution

### Risk Mitigated

- **ARC-004** (public endpoint exposure) from `02-architecture-assessment.md`
  is now fully resolved by this revised decision

## 🏛️ WAF Pillar Analysis

| Pillar      | Impact | Notes                                                                             |
| ----------- | ------ | --------------------------------------------------------------------------------- |
| Security    | ↑↑     | Backend services isolated in VNet; public internet exposure eliminated            |
| Reliability | →      | No material reliability change; private endpoints are highly available            |
| Performance | →      | VNet routing adds negligible latency; backbone traffic remains fast               |
| Cost        | ↓      | +~$23.10/mo for PE + DNS zones (modest vs. original $64.60 CA Dedicated estimate) |
| Operations  | ↓      | Additional VNet, DNS zone, and PE resources to manage and troubleshoot            |

## 🔒 Compliance Considerations

- **GDPR**: Private endpoints strengthen GDPR posture — backend data services
  are no longer reachable from the public internet; TLS 1.2 enforced
- **Azure Policy**: VNet + PE architecture satisfies common enterprise policies
  such as `deny-public-network-access` on Key Vault and Storage
- **PCI DSS**: Not in scope for this project (cash-on-delivery payment model)
- **SOC 2 / ISO 27001**: Private endpoints and network segmentation provide a
  foundation for future compliance certification if needed

## 📝 Implementation Notes

- This ADR **supersedes** the original provisional ADR-0003 (public endpoints)
- Networking cost breakdown:
  - 3 Private Endpoints × $7.20/mo = **$21.60/mo**
  - 3 Private DNS Zones × $0.50/mo = **$1.50/mo**
  - Total networking addition: **~$23.10/mo**
- Bicep modules required: `vnet.bicep`, `private-endpoint.bicep`,
  `private-dns-zone.bicep` (or equivalent AVM modules)
- VNet address space: `10.0.0.0/24` with two subnets:
  - `snet-app-service` (`10.0.0.0/27`) — delegated to `Microsoft.Web/serverFarms`
  - `snet-private-endpoints` (`10.0.0.32/27`) — hosts PE NICs
- For production: consider adding Azure Front Door Standard with WAF policy
  (~$36/mo) to protect the App Service public ingress

---

<div align="center">

> Generated by design agent | 2026-04-15 (revised)

| ⬅️ Previous                                                                                  | 📑 Index            | Next ➡️             |
| -------------------------------------------------------------------------------------------- | ------------------- | ------------------- |
| [03-des-adr-0002-table-storage-persistence.md](03-des-adr-0002-table-storage-persistence.md) | [README](README.md) | [README](README.md) |

</div>
