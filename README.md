# Red Hat Demo Agents and Skills

A collection of [Cursor IDE](https://cursor.sh) skills and rules that transform the AI agent into a multi-domain Red Hat product expert for planning and building demos, PoCs, and lab environments.

## What This Repo Contains

This repo holds **only** Cursor skills and rules -- no demo code. You and your colleagues clone this repo, install the skills globally, and then use them from any demo project with its own independent repo.

### Skills

| Skill | Description |
|-------|-------------|
| `rh-demo-orchestrator` | Coordinator that dispatches domain expert subagents for planning and building multi-product demos |
| `rh-openshift-expert` | OpenShift Container Platform, Virtualization, Quay, ACM, ACS |
| `rh-openshift-ai-expert` | OpenShift AI 3: model serving, data science pipelines, notebooks, LLMs, MLOps |
| `rh-rhel-expert` | RHEL 9, UBI9 images, Image Builder, System Roles, Edge, Podman |
| `rh-openstack-expert` | Red Hat OpenStack Platform services, Director deployment, NFVi |
| `rh-ansible-expert` | Ansible Automation Platform, Execution Environments, EDA |
| `rh-middleware-expert` | JBoss EAP, Camel, AMQ, AMQ Streams, 3scale, SSO, Quarkus, Spring Boot |
| `rh-telco-domain` | Telco cross-cutting knowledge: NFV, CNF, 5G, vRAN, O-RAN, MEC, SR-IOV, DPDK |
| `rh-certified-components` | Catalog of UBI9 images, certified operators, supported collections |

### Rules

| Rule | Description |
|------|-------------|
| `rh-demo-conventions` | Always-on baseline: UBI9 images, `podman`/`oc` CLI, certified operators, official docs |

## Quick Start

### 1. Clone the repo

```bash
git clone https://github.com/<your-org>/rh-demo-agents.git
cd rh-demo-agents
```

### 2. Install skills globally

```bash
# Copy skills to ~/.cursor/skills/ (available in every Cursor project)
./install.sh

# Or symlink so git pull auto-updates your skills
./install.sh --link

# Also install the always-on conventions rule
./install.sh --link --rules
```

### 3. Use in a demo project

Open any project in Cursor and the skills are automatically available. Start a conversation with something like:

> "Plan a demo showing 5G core deployment on OpenShift with Ansible automation for a telco customer"

The orchestrator skill will:
1. Identify the relevant domains (OpenShift, Ansible, Telco)
2. Dispatch domain expert subagents in parallel
3. Synthesize their plans into a unified demo plan
4. Guide you through the build phase

### 4. Update skills

```bash
cd rh-demo-agents
git pull

# If you used --link, you're already up to date
# If you used copy mode, re-run:
./install.sh --force
```

### 5. Uninstall

```bash
./install.sh --uninstall
```

## Architecture

```
                    User: "Plan a demo for X"
                              |
                    rh-demo-orchestrator
                   /   |    |    |    \
                  /    |    |    |     \
  rh-openshift  rh-ocp-ai rh-rhel rh-ansible rh-middleware
     expert      expert   expert   expert     expert
                  \    |    |    |     /
                   \   |    |    |    /
                  Synthesized Demo Plan
                          |
                    Build Phase
                  (subagent per task)
                          |
                    Demo Artifacts
```

### How Multi-Agent Collaboration Works

1. **Planning phase**: The orchestrator identifies which products are involved, dispatches domain expert subagents in parallel, each expert plans its portion using its specialized SKILL.md knowledge, and the orchestrator synthesizes everything into a unified plan with cross-domain review.

2. **Build phase**: The approved plan is broken into ordered tasks. For each task, a build subagent is dispatched with the relevant domain skill loaded. Each subagent produces demo artifacts (YAML manifests, Dockerfiles, Ansible playbooks, scripts) that follow Red Hat best practices and use only certified components.

The `rh-telco-domain` skill is a cross-cutting concern that augments any domain expert when the demo targets telco customers. The `rh-certified-components` skill ensures every subagent uses only supported, production-grade components.

## Repo Structure

```
rh-demo-agents/
  README.md
  LICENSE
  install.sh
  .cursor/
    rules/
      rh-demo-conventions.mdc
    skills/
      rh-demo-orchestrator/       # Coordinator
        SKILL.md
        planning-workflow.md
        building-workflow.md
      rh-openshift-expert/        # OCP, Virtualization, Quay, ACM, ACS
        SKILL.md
        ocp-reference.md
      rh-openshift-ai-expert/    # OpenShift AI 3, model serving, MLOps
        SKILL.md
        openshift-ai-reference.md
      rh-rhel-expert/             # RHEL 9, UBI9, Edge, Podman
        SKILL.md
        rhel-reference.md
      rh-openstack-expert/        # RHOSP services, Director
        SKILL.md
        openstack-reference.md
      rh-ansible-expert/          # AAP, EE, EDA
        SKILL.md
        ansible-reference.md
      rh-middleware-expert/        # JBoss, Camel, AMQ, 3scale, SSO, Quarkus
        SKILL.md
        middleware-reference.md
      rh-telco-domain/            # NFV, CNF, 5G, vRAN (cross-cutting)
        SKILL.md
        telco-patterns.md
      rh-certified-components/    # UBI9, operators, collections catalog
        SKILL.md
        certified-catalog.md
```

## Documentation

- [Getting Started with Cursor IDE](docs/getting-started-with-cursor.md) -- Installation, Git setup, AI modes, model switching, and skills installation for SAs who are new to Cursor

## Contributing

### Adding a New Skill

1. Create a directory under `.cursor/skills/` with the `rh-` prefix
2. Add a `SKILL.md` with YAML frontmatter (`name` and `description`)
3. Keep `SKILL.md` under 500 lines; put detailed reference in separate `.md` files
4. The `description` must start with "Use when..." and describe triggering conditions
5. Test the skill by opening this repo in Cursor and invoking it

### Updating an Existing Skill

1. Edit the files in `.cursor/skills/<skill-name>/`
2. Test locally
3. Submit a PR with a description of what changed and why

### Skill Writing Guidelines

- **Concise**: The AI is smart; only add knowledge it does not already have
- **Trigger-focused descriptions**: Describe when to use, not what the skill does
- **Progressive disclosure**: Essential info in SKILL.md, deep reference in separate files
- **Certified components**: Always reference `rh-certified-components` for image/operator selection
- **Official docs**: Always link to `docs.redhat.com` for product documentation

## License

Apache License 2.0. See [LICENSE](LICENSE) for details.
