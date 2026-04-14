<a id="readme-top"></a>

<div align="center">

![Status](https://img.shields.io/badge/Status-In%20Progress-yellow?style=for-the-badge)
![Step](https://img.shields.io/badge/Step-3%20of%207-blue?style=for-the-badge)
![Cost](https://img.shields.io/badge/Est.%20Cost-$24.53%2Fmo-green?style=for-the-badge)

# 🏗️ Malta Catering

**Azure-hosted online ordering demo for a Malta catering outlet selling pastizzi, Cisk, and Kinnie.**

[View Architecture](#-architecture) · [View Artifacts](#-generated-artifacts) ·
[View Progress](#-workflow-progress)

</div>

---

## 📋 Project Summary

| Property           | Value                         |
| ------------------ | ----------------------------- |
| **Created**        | 2026-04-14                    |
| **Last Updated**   | 2026-04-14                    |
| **Region**         | swedencentral                 |
| **Environment**    | demo                          |
| **Estimated Cost** | ~$24.53/month                 |
| **AVM Coverage**   | Targeted                      |

---

## ✅ Workflow Progress

```text
[##########] 43% Complete
```

| Step | Phase          |                                    Status                                     | Artifact    |
| :--: | -------------- | :---------------------------------------------------------------------------: | ----------- |
|  1   | Requirements   |  ![Done](https://img.shields.io/badge/-Done-success?style=flat-square)        | [01-requirements.md](./01-requirements.md) |
|  2   | Architecture   |  ![Done](https://img.shields.io/badge/-Done-success?style=flat-square)        | [02-architecture-assessment.md](./02-architecture-assessment.md) |
|  3   | Design         |  ![Done](https://img.shields.io/badge/-Done-success?style=flat-square)        | [03-des-diagram.drawio](./03-des-diagram.drawio) · [ADR-0001](./03-des-adr-0001-container-apps-consumption-compute.md) · [ADR-0002](./03-des-adr-0002-table-storage-persistence.md) · [ADR-0003](./03-des-adr-0003-public-network-posture.md) |
|  4   | Planning       | ![Pending](https://img.shields.io/badge/-Pending-lightgrey?style=flat-square) | Pending     |
|  5   | Implementation | ![Pending](https://img.shields.io/badge/-Pending-lightgrey?style=flat-square) | Pending     |
|  6   | Deployment     | ![Pending](https://img.shields.io/badge/-Pending-lightgrey?style=flat-square) | Pending     |
|  7   | Documentation  | ![Pending](https://img.shields.io/badge/-Pending-lightgrey?style=flat-square) | Pending     |

> **Legend**:
> ![Done](https://img.shields.io/badge/-Done-success?style=flat-square) Complete |
> ![WIP](https://img.shields.io/badge/-WIP-yellow?style=flat-square) In Progress |
> ![Pending](https://img.shields.io/badge/-Pending-lightgrey?style=flat-square) Pending |
> ![Skip](https://img.shields.io/badge/-Skipped-blue?style=flat-square) Skipped

---

## 🏛️ Architecture

Architecture preview will be generated after Step 2.

### Key Resources

| Resource           | Type                     | SKU          | Purpose                              |
| ------------------ | ------------------------ | ------------ | ------------------------------------ |
| Container Apps     | Azure Container Apps     | Consumption  | Run the containerized ordering app   |
| Container Registry | Azure Container Registry | Basic        | Store app container images           |
| Storage Account    | Azure Storage Account    | Standard LRS | Host order data and app state        |
| Table Storage      | Azure Table Storage      | Standard     | Low-cost order persistence candidate |

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
<summary><strong>📁 Planned Workflow Artifacts</strong></summary>

| File                          | Description                   |                                    Status                                     | Created |
| ----------------------------- | ----------------------------- | :---------------------------------------------------------------------------: | ------- |
| 01-requirements.md            | Project requirements artifact |      ![WIP](https://img.shields.io/badge/-WIP-yellow?style=flat-square)       | Pending |
| 02-architecture-assessment.md | WAF assessment                | ![Pending](https://img.shields.io/badge/-Pending-lightgrey?style=flat-square) | Pending |
| 03-des-cost-estimate.md       | Azure pricing estimate        | ![Pending](https://img.shields.io/badge/-Pending-lightgrey?style=flat-square) | Pending |
| 04-governance-constraints.md  | Governance constraints        | ![Pending](https://img.shields.io/badge/-Pending-lightgrey?style=flat-square) | Pending |

</details>

---

## 🔗 Related Resources

| Resource            | Path                                                                                                               |
| ------------------- | ------------------------------------------------------------------------------------------------------------------ |
| **Project Folder**  | [`agent-output/malta-catering/`](../malta-catering/)                                                               |
| **Workflow Docs**   | [Published workflow guide](https://jonathan-vella.github.io/azure-agentic-infraops/concepts/workflow/)             |
| **Troubleshooting** | [Published troubleshooting guide](https://jonathan-vella.github.io/azure-agentic-infraops/guides/troubleshooting/) |

---

<div align="center">

**Generated by [APEX](../../README.md)**

<a href="#readme-top">⬆️ Back to Top</a>

</div>
