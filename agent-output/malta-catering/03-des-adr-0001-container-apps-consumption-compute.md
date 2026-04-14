# ADR-0001: Container Apps Consumption Plan as Compute Platform

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

## 🔍 Context

The Malta Catering ordering portal needs a compute platform to host a containerized
React SPA with a lightweight API for pastizzi/Cisk/Kinnie orders. Requirements:

- **Budget**: EUR 100–500/month (soft cap); scale-to-zero preferred to minimize idle cost
- **Traffic**: 1 TPS sustained, up to 1,000 concurrent users at lunch-rush peaks
- **Operations**: Minimal ops overhead — managed TLS, no dedicated infra to manage
- **Deployment**: Containerized workload (single Docker image) via Azure Container Registry
- **Region**: `swedencentral` for GDPR EU data residency

The architecture must be simple enough for a demo/dev environment while retaining
a clear production upgrade path.

## ✅ Decision

Use **Azure Container Apps — Consumption Plan** to host both the React SPA and API
within a single containerized application.

- Single Container Apps Environment (Consumption tier, `swedencentral`)
- One Container App revision serving the full stack (React SPA served as static via
  the same container; Node.js/Python API on the same port)
- Built-in HTTPS ingress with managed TLS certificate (no cert management needed)
- Scale-to-zero with auto-scale on concurrent HTTP requests
- Managed Identity enabled for Key Vault and Storage Account access

## 🔄 Alternatives Considered

| Option                          | Pros                                                      | Cons                                                           | WAF Impact                               |
| ------------------------------- | --------------------------------------------------------- | -------------------------------------------------------------- | ---------------------------------------- |
| **Container Apps Consumption**  | Scale-to-zero, ~$10.76/mo, managed TLS, simple ops       | 2-5s cold start on first request after idle                    | Cost: ↑↑, Operations: ↑, Performance: ↓ |
| Azure App Service (Free/B1)     | Familiar, always-on, CI/CD via deployment slots           | B1 ~$13/mo always-on, no native container support on Free tier | Cost: ↓, Operations: →, Performance: ↑  |
| Azure Functions (Flex Consumption) | True per-invocation billing, great for API             | SPA hosting requires separate service; more complex            | Cost: ↑, Operations: ↓, Performance: →  |
| Container Apps Dedicated        | No cold starts, higher throughput                         | ~$50+/mo baseline; over-engineered for 1 TPS                   | Cost: ↓↓, Performance: ↑, Reliability: ↑|
| AKS (smallest node pool)        | Full orchestration, multi-service                         | Complex, ~$72/mo minimum for 1 node; no scale-to-zero          | Cost: ↓↓↓, Operations: ↓↓               |

## ⚖️ Consequences

### Positive

- Monthly cost ~$10.76 for Container Apps (within 5-25% of EUR 100-500 budget)
- Scale-to-zero eliminates idle costs outside business hours
- Built-in managed TLS removes certificate renewal burden
- Managed Identity natively supported — no secrets in environment variables
- Easy revision-based deployment model simplifies blue/green later

### Negative

- Cold start latency of 2–5 seconds on scale-from-zero affects first user after idle
- Single container model couples SPA and API — a future split requires revision changes
- Consumption plan has no SLA for cold start timing (only 99.95% availability SLA)

### Neutral

- Container Apps platform manages underlying VM infrastructure transparently
- ACR Basic integration works seamlessly without additional networking config

## 🏛️ WAF Pillar Analysis

| Pillar      | Impact | Notes                                                                     |
| ----------- | ------ | ------------------------------------------------------------------------- |
| Security    | →      | Managed Identity + TLS 1.2 maintained; no private endpoint (ARC-004)     |
| Reliability | →      | 99.95% SLA exceeds 99.0% target; cold start is inconvenient, not critical |
| Performance | ↓      | 2–5s cold start on scale-from-zero; 1 TPS well within platform capacity   |
| Cost        | ↑↑     | Scale-to-zero provides best cost profile for demo workloads               |
| Operations  | ↑      | Managed TLS, auto-scale, log integration out of the box                   |

## 🔒 Compliance Considerations

- Container Apps deploys within `swedencentral` Azure region — EU data residency satisfied
- Managed Identity eliminates credential storage, reducing GDPR data minimization risk
- No customer PII stored in container runtime environment — orders go to Table Storage
- Platform-managed encryption at rest for container runtime; no additional config needed

## 📝 Implementation Notes

- Container image should be built multi-arch (`linux/amd64`) for ACR compatibility
- Set `minReplicas: 0` for demo; change to `minReplicas: 1` before production launch
  to eliminate cold starts during peak hours
- Use `WEBSITES_PORT` / `PORT` environment variable for the container port
- Application Insights connection string should be sourced from Key Vault reference
- Revision suffix: use commit SHA for traceability (`--revision-suffix $(git rev-parse --short HEAD)`)

---

<div align="center">

> Generated by design agent | 2026-04-14

| ⬅️ Previous                                          | 📑 Index            | Next ➡️                                                                        |
| ---------------------------------------------------- | ------------------- | ------------------------------------------------------------------------------ |
| [02-architecture-assessment.md](02-architecture-assessment.md) | [README](README.md) | [03-des-adr-0002-table-storage-persistence.md](03-des-adr-0002-table-storage-persistence.md) |

</div>
