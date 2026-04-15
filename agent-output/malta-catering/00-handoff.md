# Malta Catering — Handoff (Step 6 blocked)

Updated: 2026-04-14T17:32:00Z | IaC: Bicep | Branch: main

## Completed Steps

- [x] Step 1 → agent-output/malta-catering/01-requirements.md
- [x] Step 2 → agent-output/malta-catering/02-architecture-assessment.md
- [x] Step 3 → agent-output/malta-catering/03-des-diagram.drawio
- [x] Step 3.5 → agent-output/malta-catering/04-governance-constraints.md
- [x] Step 4 → agent-output/malta-catering/04-implementation-plan.md
- [x] Step 5 → agent-output/malta-catering/05-implementation-reference.md
- [ ] Step 6 → agent-output/malta-catering/06-deployment-summary.md

## Key Decisions

- Region: swedencentral
- Compliance: GDPR
- Budget: EUR 100-500/month
- IaC Tool: Bicep
- Architecture Pattern: SPA + API on Container Apps Consumption
- Deployment Strategy: phased (foundation, security-data-images, compute, cost-monitoring)
- Governance Handling: deploy.ps1 pre-tags the resource group with all deny-required tags plus `tech-contact`
- Deployment Blocker: Azure Container Apps environment capacity is unavailable for the current free/serverless cluster path in `swedencentral`
- Selected Recovery Path: keep `swedencentral` and revise Step 5 to use a paid ACA workload profile
- Complexity: simple

## Open Challenger Findings (must_fix only)

- None

## Context for Next Step

Deployment stopped after partial success in `rg-malta-catering-dev`. `log-malta-catering-dev`, `appi-malta-catering-dev`, `stmaltadevb6lg3l`, and `acrmaltadevb6lg3l` succeeded, `kv-malta-dev-b6lg3l` is still registering DNS, and `cae-malta-catering-dev` failed with `ManagedEnvironmentCapacityHeavyUsageError`. The user selected the paid-tier remediation path, so the next agent should return to Step 5 and revise the ACA environment definition to a paid workload profile in `swedencentral`.

## Skill Context

- Default region: swedencentral; failover: germanywestcentral
- Required baseline tags: Environment, ManagedBy, Project, Owner
- Governance override: resource group must include owner, costcenter, application, workload, sla, backup-policy, maint-window, technical-contact, plus `tech-contact` for modify-policy drift
- Naming: rg-malta-catering-{env}, st{short}{env}{suffix}, kv-{short}-{env}-{suffix}, acr{short}{env}{suffix}
- Security baseline: TLS 1.2+, HTTPS-only, managed identity, storage local auth disabled, ACR admin disabled, AVM-first
- ACA Recovery: `swedencentral` supports paid workload profiles (`D4`/`D8`/`D16`/`D32`, `E4`/`E8`/`E16`/`E32`, `Flex`) if Step 5 is revised
- Review mode: simple complexity, challenger review skipped by default at Step 6

## Artifacts

- agent-output/malta-catering/00-session-state.json
- agent-output/malta-catering/00-handoff.md
- agent-output/malta-catering/04-preflight-check.md
- agent-output/malta-catering/05-implementation-reference.md
- agent-output/malta-catering/06-deployment-summary.md
- infra/bicep/malta-catering/main.bicep
- infra/bicep/malta-catering/main.bicepparam
- infra/bicep/malta-catering/azure.yaml
- infra/bicep/malta-catering/deploy.ps1
- infra/bicep/malta-catering/modules/log-analytics.bicep
- infra/bicep/malta-catering/modules/app-insights.bicep
- infra/bicep/malta-catering/modules/key-vault.bicep
- infra/bicep/malta-catering/modules/storage.bicep
- infra/bicep/malta-catering/modules/container-registry.bicep
- infra/bicep/malta-catering/modules/container-apps-env.bicep
- infra/bicep/malta-catering/modules/container-app.bicep
- infra/bicep/malta-catering/modules/budget.bicep
