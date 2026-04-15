<a id="readme-top"></a>

<a id="readme-top"></a>

<div align="center">

![Status](https://img.shields.io/badge/Status-Complete-brightgreen?style=for-the-badge)
![Step](https://img.shields.io/badge/Step-7%20of%207-blue?style=for-the-badge)
![Cost](https://img.shields.io/badge/Est.%20Cost-$139.06%2Fmo-green?style=for-the-badge)

# 🏗️ Malta Catering

**Azure-hosted online ordering demo for a Malta catering outlet selling pastizzi, Cisk, and Kinnie.**

[View Architecture](#-architecture) · [View Artifacts](#-generated-artifacts) ·
[View Progress](#-workflow-progress)

</div>

---

## 📋 Project Summary

| Property           | Value                  |
| ------------------ | ---------------------- |
| **Created**        | 2026-04-14             |
| **Last Updated**   | 2026-04-15             |
| **Region**         | swedencentral          |
| **Environment**    | dev                    |
| **Estimated Cost** | $139.06/month baseline |
| **AVM Coverage**   | Implemented            |

---

## ✅ Workflow Progress

```text
[####################] 100% Complete
```

| Step | Phase          |                                Status                                 | Artifact                                                                                                                                                                                                                          |
| :--: | -------------- | :-------------------------------------------------------------------: | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
|  1   | Requirements   | ![Done](https://img.shields.io/badge/-Done-success?style=flat-square) | [01-requirements.md](./01-requirements.md)                                                                                                                                                                                        |
|  2   | Architecture   | ![Done](https://img.shields.io/badge/-Done-success?style=flat-square) | [02-architecture-assessment.md](./02-architecture-assessment.md)                                                                                                                                                                  |
|  3   | Design         | ![Done](https://img.shields.io/badge/-Done-success?style=flat-square) | [03-des-diagram.drawio](./03-des-diagram.drawio) · [ADR-0001](./03-des-adr-0001-app-service-s1-compute.md) · [ADR-0002](./03-des-adr-0002-table-storage-persistence.md) · [ADR-0003](./03-des-adr-0003-public-network-posture.md) |
| 3.5  | Governance     | ![Done](https://img.shields.io/badge/-Done-success?style=flat-square) | [04-governance-constraints.md](./04-governance-constraints.md) · [04-governance-constraints.json](./04-governance-constraints.json)                                                                                               |
|  4   | Planning       | ![Done](https://img.shields.io/badge/-Done-success?style=flat-square) | [04-implementation-plan.md](./04-implementation-plan.md) · [dep-diagram](./04-dependency-diagram.png) · [runtime-diagram](./04-runtime-diagram.png)                                                                               |
|  5   | Implementation | ![Done](https://img.shields.io/badge/-Done-success?style=flat-square) | [04-preflight-check.md](./04-preflight-check.md) · [05-implementation-reference.md](./05-implementation-reference.md)                                                                                                             |
|  6   | Deployment     | ![Done](https://img.shields.io/badge/-Done-success?style=flat-square) | [06-deployment-summary.md](./06-deployment-summary.md)                                                                                                                                                                            |
|  7   | Documentation  | ![Done](https://img.shields.io/badge/-Done-success?style=flat-square) | [07-documentation-index.md](./07-documentation-index.md)                                                                                                                                                                          |

---

## 🏛️ Architecture

### Key Resources

| Resource            | Type                     | SKU          | Purpose                                                      |
| ------------------- | ------------------------ | ------------ | ------------------------------------------------------------ |
| App Service Plan    | Azure App Service Plan   | `P0v3`       | Dedicated Linux compute for production site and staging slot |
| Web App             | Azure App Service        | Included     | Public container host for the ordering app                   |
| Container Registry  | Azure Container Registry | Premium      | Private image source for App Service                         |
| Storage Account     | Azure Storage Account    | Standard LRS | Table-backed application persistence                         |
| Key Vault           | Azure Key Vault          | Standard     | Secret storage and Key Vault references                      |
| VNet + Private Link | Azure Networking         | N/A          | Private connectivity to backend services                     |

---

## 📄 Generated Artifacts

<details>
<summary><strong>📁 Bootstrap Artifacts</strong></summary>

| File                                                 | Description                     |                                Status                                 | Created    |
| ---------------------------------------------------- | ------------------------------- | :-------------------------------------------------------------------: | ---------- |
| [00-session-state.json](./00-session-state.json)     | Machine-readable workflow state | ![Done](https://img.shields.io/badge/-Done-success?style=flat-square) | 2026-04-14 |
| [00-handoff.md](./00-handoff.md)                     | Human-readable resume snapshot  | ![Done](https://img.shields.io/badge/-Done-success?style=flat-square) | 2026-04-14 |
| [09-lessons-learned.json](./09-lessons-learned.json) | Workflow lessons log            | ![Done](https://img.shields.io/badge/-Done-success?style=flat-square) | 2026-04-14 |

</details>

<details>
<summary><strong>📁 Workflow Artifacts</strong></summary>

| File                                                               | Description                               |                                Status                                 | Created    |
| ------------------------------------------------------------------ | ----------------------------------------- | :-------------------------------------------------------------------: | ---------- |
| [01-requirements.md](./01-requirements.md)                         | Project requirements artifact             | ![Done](https://img.shields.io/badge/-Done-success?style=flat-square) | 2026-04-14 |
| [02-architecture-assessment.md](./02-architecture-assessment.md)   | WAF assessment                            | ![Done](https://img.shields.io/badge/-Done-success?style=flat-square) | 2026-04-14 |
| [03-des-cost-estimate.md](./03-des-cost-estimate.md)               | Design-time Azure pricing estimate        | ![Done](https://img.shields.io/badge/-Done-success?style=flat-square) | 2026-04-14 |
| [04-governance-constraints.md](./04-governance-constraints.md)     | Governance constraints                    | ![Done](https://img.shields.io/badge/-Done-success?style=flat-square) | 2026-04-14 |
| [04-preflight-check.md](./04-preflight-check.md)                   | AVM and schema preflight                  | ![Done](https://img.shields.io/badge/-Done-success?style=flat-square) | 2026-04-14 |
| [05-implementation-reference.md](./05-implementation-reference.md) | Bicep scaffold and validation summary     | ![Done](https://img.shields.io/badge/-Done-success?style=flat-square) | 2026-04-14 |
| [06-deployment-summary.md](./06-deployment-summary.md)             | Successful App Service deployment summary | ![Done](https://img.shields.io/badge/-Done-success?style=flat-square) | 2026-04-15 |
| [07-documentation-index.md](./07-documentation-index.md)           | As-built package index                    | ![Done](https://img.shields.io/badge/-Done-success?style=flat-square) | 2026-04-15 |
| [07-design-document.md](./07-design-document.md)                   | As-built architecture and configuration   | ![Done](https://img.shields.io/badge/-Done-success?style=flat-square) | 2026-04-15 |
| [07-operations-runbook.md](./07-operations-runbook.md)             | Day-2 operations                          | ![Done](https://img.shields.io/badge/-Done-success?style=flat-square) | 2026-04-15 |
| [07-resource-inventory.md](./07-resource-inventory.md)             | Deployed resource inventory               | ![Done](https://img.shields.io/badge/-Done-success?style=flat-square) | 2026-04-15 |
| [07-backup-dr-plan.md](./07-backup-dr-plan.md)                     | Backup and DR guidance                    | ![Done](https://img.shields.io/badge/-Done-success?style=flat-square) | 2026-04-15 |
| [07-compliance-matrix.md](./07-compliance-matrix.md)               | Security and compliance mapping           | ![Done](https://img.shields.io/badge/-Done-success?style=flat-square) | 2026-04-15 |
| [07-ab-cost-estimate.md](./07-ab-cost-estimate.md)                 | As-built pricing baseline                 | ![Done](https://img.shields.io/badge/-Done-success?style=flat-square) | 2026-04-15 |

</details>

---

## 🔗 Related Resources

| Resource           | Path                                                                                                   |
| ------------------ | ------------------------------------------------------------------------------------------------------ |
| **Project Folder** | [agent-output/malta-catering/](../malta-catering/)                                                     |
| **Infrastructure** | [infra/bicep/malta-catering/](../../infra/bicep/malta-catering/)                                       |
| **Workflow Docs**  | [Published workflow guide](https://jonathan-vella.github.io/azure-agentic-infraops/concepts/workflow/) |

---

<div align="center">

**Generated by [APEX](../../README.md)**

<a href="#readme-top">⬆️ Back to Top</a>

</div>
