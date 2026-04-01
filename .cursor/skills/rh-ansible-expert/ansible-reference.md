# Ansible Automation Platform — detailed reference

Companion to [SKILL.md](SKILL.md). Version examples use **AAP 2.5** doc paths;
adjust minor versions to match the demo environment.

## AAP 2.x architecture

| Piece | Role |
|-------|------|
| **Automation controller** | API/UI for inventories, projects, job templates, workflows, schedules, RBAC, credentials, and job output. Executes automation using assigned execution environments. |
| **Private Automation Hub** | Hosts Ansible Collections (and container images for EEs), sync from remote hubs or Galaxy, content signing and RBAC. |
| **EDA Controller** | Runs **rulebooks**: subscribe to event **sources**, evaluate **conditions**, run **actions** (e.g. call Controller, run playbooks). |
| **Automation mesh** | Overlay of **control plane** (controller) and **execution** nodes: **hop** nodes bridge networks; **peer** links define topology; jobs target instance groups / mesh nodes for isolation and scale. |

Demos often show: Hub → sync collections → EE in Hub registry → Controller job
template using that EE → optional EDA rulebook triggering the same job on events.

## Execution environments

### Building with ansible-builder

- **`ansible-builder`** reads an **EE definition** and produces a
  `Containerfile` / build context so the image includes system packages,
  Python deps, and collections.
- Typical workflow: `ansible-builder build -t my-ee:latest -f
  execution-environment.yml` then push to Hub or a registry Controller can
  pull from.

### EE definition files

- **`execution-environment.yml`** (or `.yaml`): top-level keys commonly include
  `version`, `build_arg_defaults` (e.g. `EE_BASE_IMAGE`), `dependencies`
  (`galaxy`, `python`, `system`), and optionally `additional_build_steps`.
- **`galaxy.yml`** inside a collection is different — it describes a **collection**
  for Galaxy/Hub publish, not the EE image.

### Base EE images

- Red Hat provides **supported base images** for AAP (UBI-based); demos should
  reference the same major/minor stream as the Controller release notes.
- Custom EEs inherit from a certified base, then add `requirements.yml` (collections)
  and `requirements.txt` (Python) as needed.

## Collection structure

Published Ansible Collections are packaged with:

| Artifact / dir | Purpose |
|----------------|---------|
| **`galaxy.yml`** | Collection metadata: `namespace`, `name`, `version`, dependencies, tags, authors. |
| **`roles/`** | Optional bundled roles shipped inside the collection. |
| **`plugins/`** | `modules`, `module_utils`, `lookup`, `filter`, `inventory`, `connection`, etc. |
| **`playbooks/`** | Entry playbooks some collections ship for documented workflows. |
| **`meta/`** | Runtime requirements, action groups, extension metadata. |

Roles **inside** a collection follow the same internal layout as standalone
roles (`tasks`, `defaults`, …) under `roles/my_role/`.

## Key certified / common collections (demo-oriented)

| Collection | Typical use |
|------------|-------------|
| **ansible.builtin** | Core modules, always available; baseline for tutorials. |
| **redhat.rhel_system_roles** | RHEL system roles (time, firewall, storage, etc.) for consistent OS configuration. |
| **kubernetes.core** | Generic Kubernetes modules (`k8s`, `helm`, info modules); primary for K8s/OCP resource demos. |
| **redhat.openshift** | OpenShift-specific operations and workflows where the collection applies. |
| **ansible.netcommon** | Network resource modules, common network facts and utilities across vendors. |
| **cisco.ios** / **cisco.nxos** | Cisco IOS / NX-OS device configuration and operations. |
| **junipernetworks.junos** | Junos automation for routers/switches. |
| **awx.awx** | Manage Controller/AWX objects (projects, job templates, credentials) as code. |

Always confirm **certification** and **support** statements against the current
Hub/certification catalog for the customer’s subscription.

## Playbook patterns

| Pattern | Use |
|---------|-----|
| **Handlers** | Run once at end of play when notified (e.g. restart service only if config changed). |
| **Tags** | Limit execution (`--tags`, `--skip-tags`) for faster demos or partial runs. |
| **`block` / `rescue` / `always`** | Group tasks; catch errors in `rescue`; ensure cleanup in `always`. |
| **Error handling** | `failed_when`, `ignore_errors` (sparingly), `any_errors_fatal` at play level for strict workflows. |
| **`delegate_to`** | Run a task on a different host (e.g. localhost API call while looping over devices). |
| **`serial`** | Rolling updates: batch hosts (e.g. `serial: "10%"` or list) for canary-style deploys. |

## Role structure

Standard role layout:

| Path | Purpose |
|------|---------|
| **`defaults/main.yml`** | Low-precedence variables; easy overrides. |
| **`vars/main.yml`** | Higher-precedence internal variables (avoid secrets here). |
| **`tasks/main.yml`** | Main task entry; often `include_tasks` for platforms. |
| **`handlers/main.yml`** | Service restarts and notifications. |
| **`templates/`** | Jinja2 templates deployed with `template`. |
| **`files/`** | Static files copied with `copy`. |
| **`meta/main.yml`** | Role dependencies, Galaxy metadata, `argument_specs` for validation. |

## Event-Driven Ansible (EDA)

### Rulebook structure

- YAML rulebooks list **rules**; each rule binds **conditions** (often ansible-rulebook expression syntax) to **actions**.
- Rulebooks run in EDA Controller with a defined **activation** (project, git ref, credentials).

### Event sources (examples)

| Source | Demo idea |
|--------|-----------|
| **Webhook** | ITSM or custom HTTP caller triggers remediation. |
| **Kafka** | Stream processing, bus-driven automation. |
| **alertmanager** | Prometheus alert labels drive conditional playbooks. |

### Alertmanager-to-EDA Pattern

Alertmanager sends alerts to EDA via webhook. The rulebook matches alert names
and triggers workflow templates with structured extra_vars:

```yaml
---
- name: Cluster Alert Handler
  hosts: all
  sources:
    - ansible.eda.alertmanager:
        host: 0.0.0.0
        port: 5000
  rules:
    - name: Handle KubeNodeNotReady
      condition: >-
        event.alert.status == "firing"
        and event.alert.labels.alertname == "KubeNodeNotReady"
      action:
        run_job_template:
          name: self-healing-workflow
          organization: Default
          job_args:
            extra_vars:
              alert_name: "{{ event.alert.labels.alertname }}"
              alert_severity: "{{ event.alert.labels.severity | default('warning') }}"
              alert_node: "{{ event.alert.labels.node | default('') }}"
              alert_description: "{{ event.alert.annotations.description | default('') }}"
```

On the Alertmanager side, configure a webhook receiver:

```yaml
receivers:
  - name: eda-webhook
    webhook_configs:
      - url: "http://eda-server.aap.svc:5000/endpoint"
        send_resolved: false
```

### Conditions and actions

- **Conditions** filter which events fire which rules (severity, namespace,
  hostname regex, etc.).
- **Actions** include running job templates (via Controller), modules, debug,
  setting facts, or chaining to other rulebooks — exact set depends on EDA
  version; align with the current user guide.

## AAP-as-Code (awx.awx patterns)

### Workflow Job Templates with Conditional Branching

Define a multi-step workflow where the path depends on success/failure:

```yaml
- name: Build workflow nodes
  awx.awx.workflow_job_template_node:
    controller_host: "{{ controller_host }}"
    controller_username: "{{ controller_username }}"
    controller_password: "{{ controller_password }}"
    validate_certs: false
    workflow_job_template: "my-workflow"
    identifier: "{{ item.id }}"
    unified_job_template: "{{ item.template }}"
    state: present
  loop:
    - { id: "step1", template: "Gather Diagnostics" }
    - { id: "step2", template: "Create Incident" }
    - { id: "step3", template: "Check Knowledge Base" }
    - { id: "step4a", template: "Handle New Incident" }
    - { id: "step4b", template: "Handle Known Incident" }

- name: Link step3 with conditional branching
  awx.awx.workflow_job_template_node:
    workflow_job_template: "my-workflow"
    identifier: "step3"
    success_nodes: ["step4a"]
    failure_nodes: ["step4b"]
    state: present
```

### Passing Variables Between Workflow Steps

Use `set_stats` to pass data from one job template to the next in a workflow:

```yaml
- name: Share diagnostics with next workflow step
  ansible.builtin.set_stats:
    data:
      diagnostics: "{{ diagnostics_dict }}"
      incident_number: "{{ snow_number }}"
```

Variables set via `set_stats` are automatically available in subsequent
workflow steps as normal variables.

### Full AAP Bootstrap Pattern

A single playbook using `awx.awx` to configure the entire AAP demo environment:

1. `awx.awx.organization` -- create org
2. `awx.awx.credential` -- OpenShift token, SCM, Machine/ITSM credentials
3. `awx.awx.project` -- SCM URL (Gitea or GitHub)
4. `awx.awx.execution_environment` -- custom EE image
5. `awx.awx.inventory` + `awx.awx.host` -- inventory and hosts
6. `awx.awx.job_template` (loop) -- one per workflow step
7. `awx.awx.workflow_job_template` -- the workflow
8. `awx.awx.workflow_job_template_node` -- node creation and linking

## Execution Environment Building

### EE Definition

```yaml
---
version: 3
images:
  base_image:
    name: registry.redhat.io/ansible-automation-platform-25/ee-minimal-rhel9:latest
dependencies:
  galaxy: requirements.yml
  python: requirements.txt
  system: bindep.txt
options:
  package_manager_path: /usr/bin/microdnf
```

Build: `ansible-builder build -t quay.io/myorg/custom-ee:latest`
Push: `podman push quay.io/myorg/custom-ee:latest`

## ServiceNow Integration (servicenow.itsm)

| Module | Purpose |
|--------|---------|
| `servicenow.itsm.incident` | Create/update/close incidents |
| `servicenow.itsm.incident_info` | Query incidents |
| `servicenow.itsm.change_request` | Manage change requests |
| `servicenow.itsm.configuration_item` | Manage CMDB CIs |

Common pattern: alert -> gather diagnostics -> create incident with work notes
-> AI analysis -> update incident with RCA -> remediate -> resolve incident.

## ansible-navigator — commands and modes

| Command / mode | Notes |
|----------------|-------|
| `ansible-navigator run playbook.yml` | Run playbook; uses EE when configured. |
| `ansible-navigator images` | List available execution environment images. |
| `ansible-navigator config` | Inspect effective Ansible configuration. |
| `ansible-navigator inventory` | Browse inventory in TUI. |
| `ansible-navigator doc <fqcn>` | Module/plugin docs inside EE. |
| `--mode stdout` | Traditional line-oriented output for CI/logs. |
| Interactive (default) | TUI for exploration during live demos. |

Configuration via `ansible-navigator.yml` (EE image, pull policy, playbook
arguments, logging).

## Integration with CI/CD

| System | Pattern |
|--------|---------|
| **Jenkins** | Pipeline stage runs `ansible-navigator` or `ansible-playbook` in agent with EE; inject credentials from Jenkins credentials store or Vault. |
| **GitLab CI** | Job image with Podman/Docker to pull EE, or kubernetes executor with sidecar; protect branch deploys to Controller via `awx.awx` or API. |
| **Tekton** (OpenShift Pipelines) | Task runs automation in a UBI/tooling image; use secrets for kubeconfig and Controller OAuth token; optional EDA webhook from pipeline events. |

Demos should show **least privilege** tokens and **no long-lived passwords**
in pipeline YAML.

## Inventory patterns

| Pattern | Description |
|---------|-------------|
| **Dynamic inventory** | Inventory plugins or scripts pull hosts from cloud, satellite, CMDB, etc.; refresh per job template in Controller. |
| **Constructed inventory** | Combine sources, add groups with `compose`, keyed groups from hostvars — useful for “all RHEL9 in region X” style demos. |
| **Smart inventory (Controller)** | Controller-side filter on facts/fields to define host groups without static lists; good for large estates and policy demos. |

---

**Further reading:** [Creating and consuming execution environments](https://docs.redhat.com/en/documentation/red_hat_ansible_automation_platform/2.5/html/creating_and_consuming_execution_environments/index) · [Ansible Builder (upstream project docs)](https://ansible.readthedocs.io/projects/builder/)

**Official docs:** [Red Hat Ansible Automation Platform documentation](https://docs.redhat.com/en/documentation/red_hat_ansible_automation_platform/)
