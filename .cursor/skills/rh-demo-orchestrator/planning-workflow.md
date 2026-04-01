# Planning Workflow

Detailed steps for the orchestrator's planning phase.

## Step 1: Domain Mapping

Given the user's requirements, determine which domain experts to involve:

| Requirement mentions... | Dispatch |
|------------------------|----------|
| Containers, Kubernetes, OCP, operators, routes, registry | `rh-openshift-expert` |
| VM, virtual machine, KubeVirt, migration | `rh-openshift-expert` (Virtualization) |
| Container security, scanning, compliance | `rh-openshift-expert` (ACS) |
| Multi-cluster, fleet management | `rh-openshift-expert` (ACM) |
| AI, ML, model serving, LLM, inference, GenAI | `rh-openshift-ai-expert` |
| Data science, notebooks, Jupyter, training, fine-tuning | `rh-openshift-ai-expert` |
| RAG, vector database, model registry, MLOps | `rh-openshift-ai-expert` + `rh-middleware-expert` |
| AI agent, tool use, MCP, LlamaStack, agentic | `rh-openshift-ai-expert` + `rh-ansible-expert` |
| Self-healing, alert remediation, closed-loop ops | `rh-openshift-expert` + `rh-ansible-expert` + `rh-openshift-ai-expert` |
| Monitoring, alerting, PrometheusRule, Alertmanager | `rh-openshift-expert` |
| ServiceNow, ITSM, incident management | `rh-ansible-expert` |
| RHEL, base OS, system config, edge | `rh-rhel-expert` |
| Container images, UBI, Dockerfile | `rh-rhel-expert` + `rh-certified-components` |
| OpenStack, VMs on private cloud, NFVi | `rh-openstack-expert` |
| Automation, playbooks, config management | `rh-ansible-expert` |
| Day-2 operations, GitOps pipelines | `rh-ansible-expert` + `rh-openshift-expert` |
| Java, microservices, API gateway, messaging | `rh-middleware-expert` |
| SSO, authentication, identity | `rh-middleware-expert` (SSO) |
| Telco, 5G, RAN, NFV, CNF, MEC | `rh-telco-domain` (cross-cutting) |

**Always include `rh-certified-components` as context for every subagent.**

## Step 2: Parallel Dispatch

Dispatch all identified domain subagents simultaneously using the `Task` tool.
Each subagent receives:

- The demo goal and audience
- Constraints (environment, time, versions)
- Instructions to read its domain SKILL.md
- Instructions to read `rh-certified-components` SKILL.md
- A request to return a structured plan fragment

Do NOT dispatch sequentially unless there is a hard dependency between domains.

## Step 3: Synthesis

When all subagents return, synthesize their plan fragments:

1. **Merge components** -- combine into a single architecture view
2. **Resolve conflicts** -- if two domains propose conflicting approaches (e.g.,
   different networking models), choose the one that satisfies both
3. **Map dependencies** -- order tasks so prerequisites are built first
4. **Identify gaps** -- look for missing pieces (e.g., Ansible automation needed
   for OpenStack deployment but no Ansible expert dispatched)
5. **Estimate total effort** -- sum and adjust for integration overhead

### Dependency Resolution Order

Typical ordering for multi-product demos:

```
1. Infrastructure (RHEL / OpenStack)
2. Platform (OpenShift cluster setup)
3. Platform services (Operators, Quay, ACM, ACS)
4. AI/ML platform (OpenShift AI, GPU Operator, model serving)
5. Middleware (JBoss, AMQ, SSO, API gateway)
6. Application deployment
7. Automation (Ansible playbooks for Day-2)
8. Telco overlays (SR-IOV, DPDK, PTP if applicable)
```

## Step 4: Cross-Domain Review

Dispatch a review round where each domain expert reviews the full synthesized
plan (not just their fragment). Each reviewer checks:

- Are my domain's components correctly integrated?
- Are there missing prerequisites?
- Are the product versions compatible?
- Are certified components used throughout?

Collect feedback and apply fixes. If conflicts remain, present options to the
user.

## Step 5: User Approval

Present the final plan as a structured document:

```markdown
# Demo Plan: {TITLE}

## Goal
{One paragraph}

## Architecture
{Diagram or description}

## Components by Domain
### OpenShift
- ...
### RHEL
- ...

## Task Breakdown
1. {Task} -- {Domain} -- {Effort estimate}
2. ...

## Prerequisites
- ...

## Known Risks
- ...
```

Wait for user approval before proceeding to the build phase.
