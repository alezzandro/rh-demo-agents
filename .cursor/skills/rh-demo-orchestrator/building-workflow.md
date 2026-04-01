# Building Workflow

Detailed steps for the orchestrator's build phase.

## Prerequisites

- User has approved the demo plan from the planning phase
- A demo project repo exists (separate from the rh-demo-agents repo)
- The target environment constraints are known

## Step 1: Task Ordering

From the approved plan, extract all tasks and order them by dependency:

1. Sort by the dependency resolution order (infra -> platform -> services -> app -> automation)
2. Within each layer, tasks that are independent can run in parallel
3. Mark each task with its domain and required skill

## Step 2: Dispatch Build Subagents

For each task (or parallel group), dispatch a build subagent:

```
You are a Red Hat {DOMAIN} expert building demo artifacts.

Read and follow: ~/.cursor/skills/rh-{domain}-expert/SKILL.md
Read certified components: ~/.cursor/skills/rh-certified-components/SKILL.md

Task: {TASK_DESCRIPTION}
Context: This is part of a demo for {GOAL}. The following components have
already been built: {COMPLETED_COMPONENTS}.

Requirements:
- Use only certified/supported components
- Follow Red Hat best practices from the skill
- Generate production-quality artifacts (not throwaway scripts)
- Include comments explaining non-obvious choices

Produce:
- All necessary files (YAML manifests, Dockerfiles, playbooks, scripts)
- A brief README section explaining what was built and how to use it
- Any environment-specific notes (required env vars, secrets, endpoints)

Return: List of files created/modified with a summary of each.
```

## Step 3: Cross-Domain Consistency Check

After each layer completes, verify:

- **Naming consistency** -- services, namespaces, labels match across domains
- **Network connectivity** -- services that need to communicate can reach each other
- **Secret management** -- shared secrets are referenced consistently
- **Version alignment** -- product versions are compatible across the stack

If inconsistencies are found, dispatch a fix subagent for the affected domain.

## Step 4: Integration Verification

Once all layers are built, dispatch an integration review subagent:

```
Review the complete demo artifacts for integration issues:

1. Can all components be deployed in the stated order?
2. Are there circular dependencies?
3. Are all referenced images available in the specified registries?
4. Are all ConfigMaps, Secrets, and environment variables defined?
5. Do Ansible playbooks reference the correct hostnames/endpoints?

Return: List of issues found, or confirmation that artifacts are consistent.
```

## Step 5: Demo Repo Structure

Organize the demo project using a consistent layout that colleagues can
immediately navigate:

```
demo-project/
  README.md                      # Overview, architecture, quick start
  LICENSE
  .gitignore
  setup/                         # Numbered deployment scripts
    00-prereqs.sh                # Check prerequisites (oc, podman, etc.)
    01-install-operators.sh      # Install required operators
    02-deploy-infra.sh           # Deploy infrastructure components
    03-deploy-app.sh             # Deploy application layer
    ...
    full-setup.sh                # Runs all scripts in order
  manifests/                     # OpenShift / K8s YAML by component
    operators/                   # Subscriptions, OperatorGroups, instances
    monitoring/                  # PrometheusRule, Alertmanager config
    rhoai/                       # RHOAI resources (if applicable)
    app/                         # Application-specific manifests
  ansible/                       # Ansible automation
    playbooks/                   # Task-specific playbooks
    roles/                       # Reusable roles
    rulebooks/                   # EDA rulebooks (if applicable)
    templates/                   # Jinja2 templates (system prompts, configs)
    inventory/                   # Inventory files
    execution-environment/       # EE definition + requirements
      execution-environment.yml
      requirements.yml
      requirements.txt
      bindep.txt
  demo/                          # Runnable demo scenarios
    scenarios/
      01-scenario-name/
        trigger.sh               # Start the scenario
        cleanup.sh               # Reset to clean state
      02-another-scenario/
        trigger.sh
        cleanup.sh
    cleanup-all.sh               # Reset everything
  docs/
    architecture.md              # Component diagram, data flows
    prerequisites.md             # Required tools, accounts, sizing
    demo-walkthrough.md          # Step-by-step presenter guide
```

Each setup script should be idempotent (safe to re-run) and include error
checking. Scenario scripts should be self-contained and reversible.

## Step 6: Documentation Generation

For each demo, ensure the project repo contains:

- `README.md` -- overview, architecture, quick start, sizing requirements
- `docs/architecture.md` -- detailed architecture with component diagram and data flows
- `docs/prerequisites.md` -- what the user needs before starting (tools, accounts, cluster sizing)
- `docs/demo-walkthrough.md` -- step-by-step demo walkthrough for presenters

## Step 7: Commit and Report

- Commit all artifacts to the demo project repo with descriptive messages
- Present a summary to the user:
  - What was built (file tree)
  - How to deploy (quick start commands)
  - Known limitations or manual steps required

## Parallel vs Sequential

**Safe to parallelize:**
- Independent components within the same layer
- Documentation generation alongside artifact building
- Ansible playbooks for different target systems

**Must be sequential:**
- Infrastructure before platform (RHEL before OCP)
- Platform before services (OCP before operators)
- Services before application deployment
- Tasks within a single domain that share state

## Error Handling

If a build subagent fails:
1. Read the error output
2. Determine if it's a domain-specific issue (re-dispatch with more context)
   or a cross-domain issue (fix the integration, then retry)
3. Do not proceed to dependent tasks until the failure is resolved
4. Surface persistent failures to the user with context
