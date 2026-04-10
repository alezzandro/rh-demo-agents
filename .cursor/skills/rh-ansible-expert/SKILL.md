---
name: rh-ansible-expert
description: >-
  Use when the user plans or builds demos involving automation, Ansible,
  playbooks, configuration management, Day-2 operations, or event-driven
  automation. The agent applies this skill to shape credible architectures,
  product touchpoints, and messaging across Ansible Automation Platform 2.x
  (Controller, Hub, EDA), execution environments, collections, and mesh
  patterns without substituting for official runbooks or environment-specific
  validation.
---

# Red Hat Ansible Automation Demo Expert

Act as a **Red Hat Ansible Automation Platform (AAP) 2.x** subject-matter expert
for demo planning and implementation. Prefer certified content, supported
integration paths, and patterns aligned with product documentation. For
container base images in demos, follow **`rh-demo-conventions`** (UBI9,
`podman` on RHEL).

**Deep reference:** [ansible-reference.md](ansible-reference.md) — architecture,
execution environments, collections, playbooks, roles, EDA rulebooks,
`ansible-navigator`, inventory, and CI/CD integration.

## Scope

### Ansible Automation Platform 2.x

- **Automation controller** (formerly Ansible Tower): job templates, workflows,
  RBAC, surveys, credentials, inventories, execution environments as runtime
  images for jobs.
- **Private Automation Hub**: certified and community collection hosting,
  execution environment registry, RBAC and sync from cloud.redhat.com or
  Ansible Galaxy where applicable.
- **Event-Driven Ansible (EDA) Controller**: rulebooks, event sources, actions,
  integration with alerting and messaging for reactive automation.
- **Automation mesh**: hop nodes, peer relationships, isolated execution
  networks, scaling job distribution across sites or security zones.

### Execution environments (EEs)

Reproducible automation runtimes: **ansible-builder** definitions, base images
from Red Hat (UBI-based EEs), inclusion of collections and Python dependencies.
Demos should show **why** EEs replace ad-hoc control nodes for consistency.

### Collections

- **Certified**: supported with AAP subscriptions; prefer for customer-facing
  demos (e.g. `redhat.*`, partner-certified network/cloud collections).
- **Community**: acceptable for illustration with clear support boundaries;
  call out certification and support explicitly in narrative.

### Playbooks and roles

- **Playbook best practices**: idempotency, explicit naming, limited scope per
  play, use of `block`/`rescue`/`always`, tags, handlers, and delegation where
  appropriate.
- **Roles**: standard layout (`defaults`, `vars`, `tasks`, `handlers`,
  `templates`, `files`, `meta`); compose roles instead of monolithic playbooks
  for reusable demos.

### Tooling

- **`ansible-navigator`**: interactive exploration, lint integration, execution
  in EEs — prefer over bare `ansible-playbook` for AAP-aligned demos on RHEL.

### Event-Driven Ansible (EDA)

Rulebooks tie **sources** (webhook, Kafka, Alertmanager, etc.) to **conditions**
and **actions** (run job template, set fact, debug). Position EDA as complement
to scheduled and on-demand Controller jobs.

Key integration patterns:
- **Alertmanager webhook** -- EDA listens on a port, Alertmanager `webhook_configs`
  forwards firing alerts; rulebook conditions match `event.alert.labels.alertname`
- **Action: `run_workflow_template`** -- trigger a Controller workflow template
  with `extra_vars` extracted from the event payload (preferred over
  `run_job_template` for multi-step workflows)
- **Throttle** -- `once_within: 3 hours` with `group_by_attributes` (e.g.,
  alertname + node) to prevent duplicate triggers for the same incident
- **Alert remapping** -- conditions can remap alert names (e.g., `KubeNodePressure`
  DiskPressure -> `NodeFilesystemSpaceFillingUp`) to reuse existing remediation
- **Conditional routing** -- multiple rules in one rulebook, each matching a
  different alert name or severity

### AAP-as-Code (awx.awx)

Use the `awx.awx` collection to define Controller resources declaratively:
credentials, projects, inventories, job templates, workflow templates, and
workflow node linkage. This is the standard pattern for demo bootstrapping --
a single playbook that configures the entire AAP environment.

Key modules: `awx.awx.organization`, `awx.awx.credential`, `awx.awx.project`,
`awx.awx.inventory`, `awx.awx.job_template`, `awx.awx.workflow_job_template`,
`awx.awx.workflow_job_template_node`, `awx.awx.execution_environment`.

### Workflow Templates

AAP workflow templates chain job templates with conditional branching:
- **`success_nodes`** -- next step on success
- **`failure_nodes`** -- next step on failure (use for "known incident" routing)
- **`always_nodes`** -- next step regardless
- **`set_stats`** -- pass variables between workflow steps (e.g., incident
  number from step 1 to step 2)
- **Branching via `ansible.builtin.fail`** -- a playbook can intentionally fail
  to route the workflow to the `failure_nodes` path (e.g., "knowledge base
  match found" -> fail -> route to known-incident auto-remediation step)

### Integrations

- **Red Hat OpenShift**: `kubernetes.core` and `redhat.openshift` collections;
  cluster auth (kubeconfig, service accounts), Projects, Operators, and Day-2
  tasks suitable for demo scripts.
- **ServiceNow**: use `ansible.builtin.uri` for direct REST API calls
  (impersonation pattern: admin login + `/api/now/ui/impersonate/{sysid}`
  to act as different users like `svc-aap-automation` and `svc-ai-agent`).
  Also available: `servicenow.itsm` collection for simpler CRUD operations.
- **AI/ML**: invoke LlamaStack `/v1/chat/completions` and OpenShift Lightspeed
  `/v1/query` via `ansible.builtin.uri`; parse structured AI output with
  marker-based sections; combine with EDA for closed-loop AI-driven automation.
- **AAP Controller REST API**: use `ansible.builtin.uri` for programmatic
  operations (project sync, job template creation, credential association)
  when playbooks need to manage Controller resources dynamically at runtime.
- **Gitea/Git servers**: push files via REST API using `ansible.builtin.uri`
  (e.g., push AI-generated playbooks to a Git repo for AAP project sync).
- **Cloud providers**: use certified cloud collections where available; dynamic
  inventory from cloud APIs; align secrets with **Ansible Vault** or Controller
  credentials — never hard-code secrets in playbooks.

## Quick Reference

| Component | Purpose | Typical demo scenarios |
|-----------|---------|-------------------------|
| **Automation controller** | RBAC jobs, workflows, surveys, scheduling | Self-service provisioning, approval gates, workflow orchestration |
| **Private Automation Hub** | Curate collections and EEs | Air-gapped content, certified-only policy, EE promotion |
| **EDA Controller** | React to events with rulebooks | Alert-driven remediation, ticket integration, Kafka pipelines |
| **Automation mesh** | Distributed execution, network isolation | Multi-site, DMZ executors, scaling job capacity |
| **Execution environment** | Immutable runtime with collections/deps | Same playbook in dev/prod, builder pipeline demo |
| **Certified collections** | Supported modules and plugins | Enterprise network, RHEL, OpenShift, cloud demos |

## Common Demo Patterns

- **Network automation for telco** — device facts, config backup/standard
  templates, compliance checks using certified network collections and
  structured data (e.g. `ansible.netcommon`).
- **Day-2 OpenShift operations** — app rollout, ConfigMaps, Routes, Operators
  via `kubernetes.core` / `redhat.openshift` with cluster-scoped RBAC called
  out in the story.
- **Self-service IT with Controller surveys** — limited choice sets,
  credential separation, workflow steps for approval or notification.
- **Event-driven remediation** — Alertmanager webhook to EDA with throttle
  (`once_within: 3 hours`, `group_by_attributes`), `run_workflow_template`
  action, rulebook matches alert name/severity, triggers Controller workflow
  that gathers diagnostics, opens ITSM ticket, invokes AI analysis, and
  applies fix.
- **AAP-as-code bootstrap** — single playbook using `awx.awx` to define
  credentials, project (SCM), EE, job templates, and workflow template with
  conditional branching (success/failure nodes).
- **Self-healing with dual RAG** — EDA triggers workflow; playbooks gather
  diagnostics (`kubernetes.core`), query OpenShift Lightspeed (`/v1/query`)
  for product docs, search LlamaStack vector store for operational KB, call
  LlamaStack `/v1/chat/completions` with combined context, parse structured
  output (RCA + playbook + extra_vars via markers), push playbook to Git,
  create AAP Job Template via Controller REST API, update ServiceNow.
- **Workflow branching via fail** — `check-knowledge-base.yml` queries AAP
  for existing remediation JT; if found, `ansible.builtin.fail` routes
  workflow to `failure_nodes` (known-incident auto-remediation path);
  if not found, success path invokes AI for new analysis.
- **ServiceNow impersonation** — admin authenticates, then impersonates
  service users (`svc-aap-automation`, `svc-ai-agent`) via REST API to
  show different actors updating the same incident.
- **Multi-tier app deployment** — roles per tier, rolling updates with
  `serial`, handlers for restarts, smoke tests in `block`/`rescue`.

## Best Practices

- **Use collections, not ad-hoc raw modules** where a maintained collection
  exists; pin versions for reproducible demos.
- **Use execution environments** for all runnable demos; document base image
  and included collections in README or job metadata.
- **Use `ansible-navigator`** over `ansible-playbook` when demonstrating
  creator or operator workflows on RHEL-class workstations.
- **Use Ansible Vault or Controller credentials** for secrets; never commit
  cleartext passwords or API tokens.
- **Lint with `ansible-lint`** (and controller policy where shown) before
  presenting playbooks as “production-like.”

## Documentation References

- [Red Hat Ansible Automation Platform product documentation](https://docs.redhat.com/en/documentation/red_hat_ansible_automation_platform/)
- [Installing Ansible Automation Platform](https://docs.redhat.com/en/documentation/red_hat_ansible_automation_platform/2.5/html/installing_on_openshift_container_platform/index)
- [Automation controller user guide](https://docs.redhat.com/en/documentation/red_hat_ansible_automation_platform/2.5/html/automation_controller_user_guide/index)
- [Private Automation Hub user guide](https://docs.redhat.com/en/documentation/red_hat_ansible_automation_platform/2.5/html/managing_automation_content/index)
- [Event-Driven Ansible Controller user guide](https://docs.redhat.com/en/documentation/red_hat_ansible_automation_platform/2.5/html/event-driven_ansible_controller_user_guide/index)
- [Automation content navigator creator guide](https://docs.redhat.com/en/documentation/red_hat_ansible_automation_platform/2.5/html/automation_content_navigator_creator_guide/index)
- [Using automation mesh](https://docs.redhat.com/en/documentation/red_hat_ansible_automation_platform/2.5/html/automation_mesh/index)
- [Creating and consuming execution environments](https://docs.redhat.com/en/documentation/red_hat_ansible_automation_platform/2.5/html/creating_and_consuming_execution_environments/index)
