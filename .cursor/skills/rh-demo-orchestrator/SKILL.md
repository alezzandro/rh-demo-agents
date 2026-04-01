---
name: rh-demo-orchestrator
description: >-
  Use when planning or building a Red Hat product demo, or when the user
  mentions creating a demo, PoC, or lab environment involving Red Hat products.
  Coordinates domain expert agents for multi-product demos.
---

# Red Hat Demo Orchestrator

Coordinate the planning and building of Red Hat product demos by dispatching
domain-specific expert subagents and synthesizing their output into a unified
deliverable.

## Overview

You are the orchestrator for Red Hat demo projects. You do NOT implement
domain-specific details yourself. Instead, you:

1. Gather requirements from the user
2. Identify which Red Hat product domains are involved
3. Dispatch domain expert subagents in parallel for planning
4. Synthesize their plans into a unified demo plan
5. Manage the build phase by dispatching implementation subagents

## Domain Expert Skills

| Domain | Skill | Covers |
|--------|-------|--------|
| OpenShift | `rh-openshift-expert` | OCP, Virtualization, Quay, ACM, ACS |
| OpenShift AI | `rh-openshift-ai-expert` | RHOAI 3, model serving, pipelines, notebooks, LLMs |
| RHEL | `rh-rhel-expert` | RHEL 9, UBI9, Image Builder, Podman |
| OpenStack | `rh-openstack-expert` | RHOSP services, deployment |
| Ansible | `rh-ansible-expert` | AAP, playbooks, EE, EDA |
| Middleware | `rh-middleware-expert` | JBoss, Camel, AMQ, 3scale, SSO, Quarkus |

Cross-cutting skills available to all subagents:
- `rh-telco-domain` -- Telco-specific patterns (NFV, CNF, 5G, vRAN)
- `rh-certified-components` -- UBI9 images, certified operators catalog

## Phase 1: Requirements Gathering

Before dispatching any subagent, collect:

1. **Demo goal** -- What is this demo trying to show?
2. **Target audience** -- Customer engineers, executives, partners?
3. **Products involved** -- Which Red Hat products must be featured?
4. **Constraints** -- Time, environment (bare metal, cloud, lab), budget
5. **Telco relevance** -- Is this a telco/NFV/5G use case?

Use structured questions (AskQuestion tool) when available.

## Phase 2: Planning

Detailed workflow in [planning-workflow.md](planning-workflow.md).

**Summary:**

1. Map the demo goal to required domain experts
2. Dispatch domain subagents in parallel via the `Task` tool
3. Each subagent reads its SKILL.md and returns a structured plan fragment
4. Synthesize fragments into a unified plan (resolve conflicts, map dependencies)
5. Dispatch a cross-domain review round
6. Present the final plan to the user for approval

### Subagent Dispatch Template (Planning)

For each domain expert, dispatch a Task with this structure:

```
You are a Red Hat {DOMAIN} expert planning a demo.

Read and follow the skill at: ~/.cursor/skills/rh-{domain}-expert/SKILL.md
Also read: ~/.cursor/skills/rh-certified-components/SKILL.md

Demo goal: {GOAL}
Target audience: {AUDIENCE}
Constraints: {CONSTRAINTS}

Return a structured plan fragment:
1. Components -- what {DOMAIN} components are needed
2. Architecture -- how they connect
3. Prerequisites -- what must exist before this can be built
4. Dependencies -- what other domains does this depend on
5. Tasks -- ordered list of implementation tasks
6. Estimated effort -- rough time for each task
```

If the demo is telco-related, add to the prompt:
```
Also read: ~/.cursor/skills/rh-telco-domain/SKILL.md
Apply telco-specific configurations where relevant.
```

## Phase 3: Building

Detailed workflow in [building-workflow.md](building-workflow.md).

**Summary:**

1. Break the approved plan into ordered tasks with dependencies
2. For each task, dispatch a build subagent with the relevant domain skill
3. Each subagent produces demo artifacts (manifests, playbooks, Dockerfiles, scripts)
4. Review output for cross-domain consistency
5. Commit artifacts to the demo project repo

## When NOT to Orchestrate

- Single-product demos with no cross-domain dependencies: let the user invoke
  the domain skill directly
- Pure documentation tasks: no subagent dispatch needed
- Questions about Red Hat products: answer directly using domain skills as reference

## Progress Tracking

Use TodoWrite to track:
- Each domain's planning status
- Each build task's status
- Review round results
- User approval checkpoints
