<!-- markdownlint-disable MD013 MD033 MD041 -->

# APEX at The Perspectives 2026

<div align="center">
  <img
    src="https://capsule-render.vercel.app/api?type=waving&height=180&color=0:0A66C2,50:0078D4,110:00B7C3&text=APEX&fontSize=44&fontColor=FFFFFF&fontAlignY=34&desc=Live%20Demo%20Workspace%20for%20The%20Perspectives%202026&descAlignY=56"
    alt="APEX live demo banner" />
</div>

> APEX is the Agentic Platform Engineering eXperience for Azure.
> This repository is the live demo workspace for Jonathan Vella's session at
> [The Perspectives 2026](https://tech.bmit.com.mt/the-perspectives-2026).

[![Event](https://img.shields.io/badge/BMIT-The_Perspectives_2026-0A66C2)](https://tech.bmit.com.mt/the-perspectives-2026)
[![Docs](https://img.shields.io/badge/APEX-Live_Documentation-0078D4)](https://jonathan-vella.github.io/azure-agentic-infraops/)
[![Demo](https://img.shields.io/badge/APEX-Nordic_Fresh_Foods_Demo-00B7C3)](https://jonathan-vella.github.io/azure-agentic-infraops/demo/)
[![Copilot](https://img.shields.io/badge/GitHub_Copilot-GPT--powered-000000?logo=github-copilot&logoColor=white)](https://github.com/features/copilot)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

## Why This Matters Today

The event theme is practical cloud leadership: reducing complexity, improving resilience,
and making better infrastructure decisions under compliance and cost pressure.

APEX is built for exactly that problem space. It turns a plain-language infrastructure ask
into a structured delivery flow with AI agents doing the preparation work and humans keeping
control over approvals, trade-offs, and deployment decisions.

## What APEX Does

1. Captures business and technical requirements from natural-language prompts.
2. Assesses target architecture against Azure Well-Architected guidance.
3. Discovers governance and policy constraints before code generation.
4. Produces Bicep or Terraform using Azure Verified Modules where possible.
5. Validates outputs and assembles deployment-ready and as-built documentation.

## What I Am Showing in the Live Demo

- A real multi-step agent workflow from prompt to Azure delivery artifacts.
- Human approval gates instead of blind automation.
- Architecture, pricing, governance, and implementation decisions in one flow.
- Demo outputs based on the Nordic Fresh Foods scenario published on the APEX site.

## Follow Along

| Experience       | Link                                                                                                | What you will find                                       |
| ---------------- | --------------------------------------------------------------------------------------------------- | -------------------------------------------------------- |
| Main site        | [APEX documentation](https://jonathan-vella.github.io/azure-agentic-infraops/)                      | Product overview, workflow, and getting started guidance |
| Demo walkthrough | [Nordic Fresh Foods demo](https://jonathan-vella.github.io/azure-agentic-infraops/demo/)            | Real generated outputs across the full pipeline          |
| How it works     | [Workflow overview](https://jonathan-vella.github.io/azure-agentic-infraops/concepts/how-it-works/) | The agent pipeline, reviews, and approval model          |
| Prompt examples  | [Prompt guide](https://jonathan-vella.github.io/azure-agentic-infraops/guides/prompt-guide/)        | Reusable prompts for agents and common scenarios         |
| Source repo      | [GitHub repository](https://github.com/jonathan-vella/azure-agentic-infraops)                       | The maintained upstream APEX codebase                    |

## Demo Flow

The live session focuses on a simple question: how do you get from a business requirement
to governed, reviewable Azure infrastructure without losing rigor?

1. Start with a requirement prompt in GitHub Copilot Chat.
2. Let APEX route that request through requirements, architecture, and governance analysis.
3. Review the generated IaC plan and code outputs.
4. Validate the result before any deployment decision is made.
5. Finish with the documentation and artifact trail that operations teams actually need.

## Repository Map

```text
.github/            # Agents, skills, instructions, prompts, hooks, and workflows
agent-output/       # Generated artifacts for each scenario or project
infra/              # Bicep and Terraform outputs
mcp/                # MCP servers used by the workflow
scripts/            # Validation, sync, and demo support scripts
site/               # Published documentation site source
tests/              # Validation fixtures, prompts, and E2E inputs
```

## Explore This Workspace Locally

```bash
git clone https://github.com/jonathan-vella/bmit-2026.git
cd bmit-2026
code .
npm install
```

Useful commands during or after the session:

```bash
# Run the full validation suite
npm run validate:all

# Start the documentation site locally
npm run docs:dev

# Validate the end-to-end demo artifacts
npm run e2e:validate
```

## After the Session

If you want to keep exploring APEX after the event, start here:

- [APEX documentation site](https://jonathan-vella.github.io/azure-agentic-infraops/)
- [APEX upstream repository](https://github.com/jonathan-vella/azure-agentic-infraops)
- [APEX MicroHack](https://jonathan-vella.github.io/microhack-agentic-infraops/)

## License

[MIT](LICENSE)
