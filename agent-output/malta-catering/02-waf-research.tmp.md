# WAF Research Notes (scratch file)

## Architecture Stack

| # | Resource | SKU / Tier | Config | AVM Module |
|---|----------|-----------|--------|------------|
| 1 | Container Apps Environment | Consumption (serverless) | Single revision, 0-1 replicas | `avm/res/app/managed-environment:0.8.0` |
| 2 | Container App | Consumption | 0.25 vCPU, 0.5 GiB RAM, HTTP ingress | `avm/res/app/container-app:0.11.0` |
| 3 | Container Registry | Basic | 10 GiB storage, no geo-replication | `avm/res/container-registry/registry:0.6.0` |
| 4 | Storage Account (Table) | Standard LRS | V2, Table Storage for orders/menu | `avm/res/storage/storage-account:0.14.0` |
| 5 | Key Vault | Standard | RBAC auth, managed identity access | `avm/res/key-vault/vault:0.11.0` |
| 6 | Log Analytics Workspace | Per-GB (free tier 5 GB/month) | Container Apps auto-provisioned | `avm/res/operational-insights/workspace:0.9.0` |

## WAF Pillar Scores

### Security: 7/10 (High confidence)
**Strengths**: Managed identity for service-to-service auth; Key Vault for secrets;
TLS 1.2+ enforced on Container Apps ingress and Storage; RBAC on Key Vault; no
PCI scope (cash on delivery); platform-managed encryption at rest.
**Gaps**: No private endpoints (public ingress); no WAF/DDoS; social IdP data
leaves EU (acknowledged risk per REQ-002); staff auth model is application-level
rather than Entra-backed.
**No deprecated services.**

### Reliability: 6/10 (Medium confidence)
**Strengths**: Container Apps Consumption plan has built-in health probes and
auto-restart; Storage Account LRS provides 11 nines durability within region;
ACR Basic stores images durably; single-region is acceptable for 99.0% SLA
target.
**Gaps**: No failover region; Table Storage has no native backup/restore
(REQ-001 finding); no availability zones (not required at 99.0% target);
single container replica by default.
Container Apps Consumption SLA: 99.95% (exceeds 99.0% target).

### Performance: 8/10 (High confidence)
**Strengths**: 1 TPS is trivially low for Container Apps (supports thousands);
Table Storage supports 20,000 TPS per storage account — 1 TPS is negligible;
Consumption plan scales to zero and up automatically; React SPA can be
served from Container Apps or CDN.
**Gaps**: No CDN for static assets (acceptable for demo); 30s polling for
order status is acceptable per REQ-005 finding; cold start possible on
scale-from-zero (typically 2-5 seconds).

### Cost Optimization: 9/10 (High confidence)
**Strengths**: Consumption plan = pay per vCPU-second and GiB-second;
scale-to-zero when idle; ACR Basic is cheapest tier; Standard LRS is cheapest
durable storage; Log Analytics free tier (5 GB/month) likely sufficient;
Key Vault Standard charges per operation (negligible at 1 TPS).
**Gaps**: ACR Basic has limited throughput (adequate for demo).

### Operational Excellence: 6/10 (Medium confidence)
**Strengths**: Container Apps provides built-in logging to Log Analytics;
managed TLS certificates; automatic HTTPS; simple deployment model
(single container revision).
**Gaps**: No custom alerts; no runbook automation; no CI/CD pipeline
defined yet; manual scaling decisions; best-effort support model.

## Service Maturity
All services are GA and actively maintained. No deprecation notices.
Container Apps went GA in May 2022.
Table Storage has been GA since 2012.
Key Vault Standard has been GA since 2015.
ACR Basic has been GA since 2017.

## Region: swedencentral
All services available. Verified via docs.

## Open Risk from REQ-001
Table Storage backup: For demo, accept risk. Document that production would
need a scheduled Azure Function or Logic App to export table data to blob
storage for point-in-time recovery.
