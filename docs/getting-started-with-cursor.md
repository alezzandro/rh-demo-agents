# Getting Started with Cursor IDE -- A Guide for Red Hat Solution Architects

This guide walks you through installing Cursor, setting up Git for safe
version control, and using the AI-powered features that make Cursor valuable
for Solution Architects working with Red Hat products. No prior IDE experience
is assumed.

---

## Table of Contents

1. [What Is Cursor and Why It Matters](#1-what-is-cursor-and-why-it-matters)
2. [Installing Cursor](#2-installing-cursor)
3. [Setting Up Git for Data Safety](#3-setting-up-git-for-data-safety)
4. [The Three AI Modes](#4-the-three-ai-modes)
5. [Choosing and Switching AI Models](#5-choosing-and-switching-ai-models)
6. [The Value of Skills and Rules](#6-the-value-of-skills-and-rules)
7. [Installing the Red Hat Demo Skills](#7-installing-the-red-hat-demo-skills)

---

## 1. What Is Cursor and Why It Matters

### What is an IDE?

An IDE (Integrated Development Environment) is a text editor with built-in
tools for working with code and configuration files. Instead of switching
between a terminal, a text editor, and a browser, everything lives in one
window: file browsing, editing, terminal access, Git integration, and search.

### What makes Cursor different?

Cursor is built on the same foundation as Visual Studio Code (VS Code), so it
inherits all of those standard IDE features. What it adds is a deeply
integrated AI assistant that can:

- **Read and write files** across your entire project
- **Run terminal commands** on your behalf
- **Reason about architecture** across multiple Red Hat products
- **Generate YAML manifests**, Ansible playbooks, Containerfiles, and scripts
- **Plan before building**, letting you review and approve an approach first
- **Switch between AI models** (Claude, GPT, and others) depending on the task

### Why this matters for Solution Architects

As an SA, you spend time designing architectures, planning demos, writing
proposals, and building proof-of-concept environments that span multiple Red
Hat products. Cursor with AI turns that workflow into a conversation:

- *"Plan a self-healing demo with OpenShift, AAP, and OpenShift AI for a
  telco customer"* -- and the AI designs the architecture, identifies the
  products, and proposes an implementation plan.
- *"Generate the Ansible playbooks and OpenShift manifests for this demo"* --
  and the AI writes production-quality artifacts using certified components.
- *"Explain what this Helm chart does"* -- and the AI reads the files and
  gives you a clear breakdown.

Cursor offers several subscription tiers. Check with your organization for
details on which plan is available to you.

---

## 2. Installing Cursor

### Linux (RHEL / Fedora)

#### Option A: DNF repository (recommended)

This gives you automatic updates through your package manager.

1. Add the Cursor repository:

```bash
sudo tee /etc/yum.repos.d/cursor.repo << 'EOF'
[cursor]
name=Cursor
baseurl=https://downloads.cursor.com/yumrepo
enabled=1
gpgcheck=1
gpgkey=https://downloads.cursor.com/keys/anysphere.asc
EOF
```

2. Install Cursor:

```bash
sudo dnf install cursor
```

3. Launch Cursor from your application menu, or from the terminal:

```bash
cursor
```

#### Option B: AppImage (portable, no root required)

If you prefer not to add a system repository, download the AppImage:

```bash
wget "https://downloader.cursor.sh/linux/appImage/x64" -O cursor.AppImage
chmod +x cursor.AppImage
./cursor.AppImage
```

> **Note:** If you see a `libfuse.so.2` error, install the FUSE 2 library:
>
> ```bash
> sudo dnf install fuse-libs    # Fedora / RHEL
> ```

#### Adding the `cursor` command to your terminal

If Cursor does not add itself to your PATH automatically:

1. Open Cursor
2. Press `Ctrl+Shift+P` to open the Command Palette
3. Type `Shell Command: Install 'cursor' command in PATH` and select it
4. Restart your terminal

Now you can open any folder with `cursor /path/to/project` or `cursor .`
from within a directory.

### macOS

#### Option A: Homebrew (recommended)

```bash
brew install --cask cursor
```

This handles code signing and quarantine flags automatically.

#### Option B: Direct download

1. Go to [cursor.com](https://cursor.com) and download the `.dmg` file
2. Open the `.dmg` and drag Cursor into your Applications folder
3. Launch Cursor from Applications

> **Note:** If you see "Cursor is damaged and can't be opened", run:
>
> ```bash
> xattr -cr /Applications/Cursor.app
> ```
>
> If you see "developer cannot be verified", go to **System Settings >
> Privacy & Security** and click **Open Anyway**.

Cursor supports both Apple Silicon (M1/M2/M3/M4) and Intel Macs.

#### Adding the `cursor` command to your terminal

1. Open Cursor
2. Press `Cmd+Shift+P` to open the Command Palette
3. Type `Shell Command: Install 'cursor' command in PATH` and select it
4. Restart your terminal

### First launch

When you open Cursor for the first time:

1. **Theme** -- pick Light or Dark (you can change this later in Settings)
2. **Sign in** -- use your Cursor account (create one at
   [cursor.com](https://cursor.com) if you do not have one yet)
3. **Extensions** -- Cursor comes with sensible defaults; you can add
   extensions later as needed (YAML, Ansible, Python, etc.)

> **Tip:** To open Settings at any time, press `Ctrl+,` (Linux) or `Cmd+,`
> (macOS).

---

## 3. Setting Up Git for Data Safety

Git is a version control system that keeps a complete history of every change
you make to your files. Think of it as an unlimited undo history that also
lets you create branches to experiment safely. **This is your safety net** --
if the AI generates something you do not want, you can always revert.

### Installing Git

**Linux (RHEL / Fedora):**

```bash
sudo dnf install git
```

**macOS:**

```bash
brew install git
```

Or install the Xcode Command Line Tools, which include Git:

```bash
xcode-select --install
```

### Configuring your identity

Git tags every commit with your name and email. Set these once:

```bash
git config --global user.name "Your Name"
git config --global user.email "your.name@redhat.com"
```

### Creating a local repository for a demo project

Every demo project should live in its own Git repository. Here is how to
start one from scratch:

```bash
mkdir ~/demos/my-openshift-demo
cd ~/demos/my-openshift-demo
git init
```

This creates a hidden `.git/` directory that tracks all changes. Now create an
initial file and make your first commit:

```bash
echo "# My OpenShift Demo" > README.md
git add README.md
git commit -m "Initial commit"
```

> **Key concept:** A commit is a snapshot of your project at a point in time.
> You can always go back to any previous commit.

### Opening the project in Cursor

```bash
cursor ~/demos/my-openshift-demo
```

Or launch Cursor and use **File > Open Folder** to navigate to the directory.

### Using the Source Control panel

Cursor has a built-in Git interface. Open it with:

- **Linux:** `Ctrl+Shift+G`
- **macOS:** `Cmd+Shift+G`

The Source Control panel shows:

- **Modified files** -- files you have changed since the last commit
- **Staged files** -- files you have selected to include in the next commit
- **A commit message box** -- type your message and press `Ctrl+Enter`
  (`Cmd+Enter` on macOS) to commit

#### AI-generated commit messages

Click the **sparkle icon** next to the commit message box and Cursor will
read your changes and write a descriptive commit message for you. Review it,
edit if needed, and commit.

### Branching for experiments

Before making big changes (or letting the AI do so), create a branch:

```bash
git checkout -b experiment/self-healing-demo
```

You can also click the branch name in the bottom-left corner of Cursor to
create or switch branches. If the experiment does not work out, switch back
to `main` and your original code is untouched:

```bash
git checkout main
```

### Connecting to a remote repository (optional)

To back up your work to GitHub or GitLab:

```bash
git remote add origin https://github.com/your-org/my-openshift-demo.git
git push -u origin main
```

> **Golden rule: commit early, commit often.** Every time you reach a working
> state -- even a small one -- commit. This gives you restore points and
> protects against any unwanted AI changes.

---

## 4. The Three AI Modes

Cursor's AI assistant operates in three modes, each designed for a different
type of work. You can switch between them at any time.

### Agent Mode (default)

Agent is the most powerful mode. It can read files, write files, run terminal
commands, install dependencies, and build entire projects. This is where you
spend most of your time when creating demos.

**What it does:**
- Reads your project files to understand context
- Creates and edits files across the project
- Runs shell commands (`oc`, `ansible-navigator`, `podman`, etc.)
- Manages multi-step tasks with progress tracking

**SA example:**

> *"Create an Ansible playbook that deploys a vLLM InferenceService on
> OpenShift AI with a custom ServingRuntime for Mistral Small 3.1 24B."*

Agent will generate the YAML manifests, write them to your project, and can
even apply them if you have `oc` configured.

### Ask Mode

Ask is a **read-only** mode. The AI can read your files and answer questions
but it cannot make any changes. Use this when you want to understand existing
code or get advice without risking modifications.

**What it does:**
- Reads and analyzes your project files
- Answers questions about architecture, configuration, and logic
- Explains what code does in plain language
- Cannot modify files or run commands

**SA example:**

> *"Explain the data flow in this EDA rulebook -- what happens when a
> KubeNodeNotReady alert fires?"*

Ask mode will trace through the rulebook, identify the conditions, and
explain the workflow step by step.

### Plan Mode

Plan is a **collaborative design** mode. The AI researches your codebase,
asks clarifying questions, and produces a structured implementation plan.
Nothing is built until you review and approve the plan.

**What it does:**
- Explores your project to understand the current state
- Asks clarifying questions about requirements and constraints
- Produces a step-by-step plan with file paths and code snippets
- Waits for your approval before making any changes

**SA example:**

> *"Plan a demo that shows a self-healing OpenShift cluster using AAP
> Event-Driven Ansible, OpenShift AI with LlamaStack, and ServiceNow
> integration for a telco customer."*

Plan mode will identify the products involved, propose an architecture, list
the artifacts to create, and present the plan for your review. Once you
approve, you can switch to Agent mode to execute it.

### How to switch modes

There are two ways to switch:

1. **Mode picker** -- click the mode dropdown at the bottom of the chat panel
   and select Agent, Ask, or Plan
2. **Keyboard shortcut** -- press `Shift+Tab` to cycle through the modes

> **Tip:** Start complex tasks in **Plan** mode to design the approach, switch
> to **Agent** mode to execute, and use **Ask** mode whenever you need to
> understand something without changing it.

---

## 5. Choosing and Switching AI Models

Cursor gives you access to multiple AI models, each with different strengths.
You can switch models at any time depending on the task.

### Where to find the model selector

The **model dropdown** is located directly underneath the chat input box. Click
it to see the list of available models.

### Available models

Depending on your Cursor subscription tier, you have access to several
models. The most relevant ones:

| Model | Best for |
|-------|----------|
| **Claude Sonnet 4.6** | Everyday tasks: generating playbooks, writing YAML, explaining code. Fast and capable. |
| **Claude Opus 4.6** | Complex multi-step reasoning: architecture design, large refactors, multi-product demo planning. The most capable model. |
| **GPT-4o** | Alternative perspective, structured output. Good second opinion. |

### Enabling additional models

Some models may not be visible in the dropdown by default. To enable them:

1. Open Cursor Settings (`Ctrl+,` on Linux, `Cmd+,` on macOS)
2. Go to the **Models** tab
3. Find the model you want (e.g., Claude Opus 4.6) and toggle it **on**
4. The model now appears in the dropdown

### Setting a default model

In **Settings > Models**, use the **Default Model** dropdown to select which
model Cursor uses when you start a new conversation. You can override this
per-conversation using the model dropdown in the chat panel.

### Practical guidance for SAs

- **Starting a new demo plan?** Use **Claude Opus 4.6** in **Plan mode**. Its
  deeper reasoning produces better architectures and catches cross-product
  integration issues.
- **Generating manifests and playbooks?** Use **Claude Sonnet 4.6** in
  **Agent mode**. It is fast and produces high-quality code.
- **Reviewing someone else's work?** Use **Claude Sonnet 4.6** in **Ask
  mode**. It reads quickly and explains clearly.
- **Want a second opinion?** Switch to **GPT-4o** and ask the same question.
  Different models sometimes catch different issues.

> **Tip:** You can change the model mid-conversation. If Sonnet is struggling
> with a complex architectural decision, switch to Opus for that specific
> question and then switch back.

---

## 6. The Value of Skills and Rules

Cursor becomes dramatically more useful when you teach the AI about your
specific domain. This is done through two mechanisms: **Rules** and
**Skills**.

### Rules: always-on guardrails

Rules are short, imperative instructions that apply automatically to **every
conversation** in a project. They enforce standards so you do not have to
remember them.

Rules live in `.cursor/rules/` as `.mdc` files. When a rule is marked as
`alwaysApply: true`, it is injected into every AI interaction automatically.

**Example: `rh-demo-conventions`**

This rule ensures that every piece of output the AI generates follows Red Hat
standards:

- Always use **UBI9** as the base container image (never Alpine or Debian)
- Use `podman` instead of `docker`, `oc` instead of `kubectl`
- Name build files `Containerfile` (not `Dockerfile`)
- Deploy via certified Operators from the Red Hat catalog
- Use `ansible-navigator` over `ansible-playbook`
- Never hard-code secrets; generate dynamically and store in git-ignored files
- Follow the standard demo project structure (`setup/`, `manifests/`,
  `ansible/`, `demo/scenarios/`)

Without this rule, you would have to remind the AI of these conventions in
every conversation. With the rule active, the AI follows them by default.

### Skills: deep domain knowledge on demand

Skills are Markdown files that teach the AI specialized knowledge about a
specific domain. Unlike rules (which are always active), skills are loaded
**when the AI detects that they are relevant** to your request.

Each skill contains:

- A **description** that tells the AI when to activate (e.g., "Use when
  planning or building demos involving OpenShift AI")
- **Product knowledge** -- components, CRDs, APIs, integration patterns
- **Best practices** -- what to use, what to avoid, and why
- **Common demo patterns** -- proven architectures the AI can draw from
- **Reference material** -- detailed CRD examples, API endpoints, CLI
  commands

**Example:** When you mention "5G core deployment" in a conversation, Cursor
detects the telco keywords and loads the `rh-telco-domain` skill. The AI
then knows about SR-IOV, DPDK, PTP, and NUMA-aware scheduling -- knowledge
it would not have otherwise.

### Why this matters for SAs

The combination of rules and skills means that:

1. **Every output follows Red Hat standards** -- UBI9 images, certified
   operators, official CLI tools, proper naming conventions
2. **The AI has deep product knowledge** -- it knows about OpenShift AI
   components, AAP workflow patterns, EDA rulebook syntax, and telco-specific
   configurations
3. **Results are consistent across colleagues** -- everyone using the same
   skills gets the same quality of output, aligned with product documentation
4. **You do not have to be an expert in every product** -- the skills carry
   the domain knowledge, so you can confidently plan demos that span products
   you are less familiar with

---

## 7. Installing the Red Hat Demo Skills

We have built a collection of skills and rules specifically for Red Hat
Solution Architects. They cover OpenShift, OpenShift AI, RHEL, Ansible,
OpenStack, Middleware, Telco, and certified component catalogs.

The full list is in the project [README](../README.md).

### Step 1: Clone the repository

```bash
git clone https://github.com/alezzandro/rh-demo-agents.git
cd rh-demo-agents
```

### Step 2: Install with symlinks and rules

```bash
./install.sh --link --rules
```

This command does two things:

- **`--link`** creates symbolic links from `~/.cursor/skills/` to the
  repository. This means that when you `git pull` to get updated skills,
  your Cursor installation is automatically up to date. No need to re-run
  the installer.

- **`--rules`** also installs the `rh-demo-conventions` rule to
  `~/.cursor/rules/`. This is the always-on guardrail that enforces UBI9
  images, certified operators, `podman`/`oc` CLI, and the standard demo
  project structure.

> **Why `--link --rules`?** Symlinks keep you in sync with the team.
> Including `--rules` means the Red Hat conventions apply automatically to
> every project you open -- you never have to think about it.

### Step 3: Verify the installation

1. Open any project in Cursor (or create a new one)
2. Open the chat panel (`Ctrl+L` on Linux, `Cmd+L` on macOS)
3. Try a prompt that mentions Red Hat products:

> *"Plan a demo showing OpenShift AI model serving with vLLM and Ansible
> automation for Day-2 operations."*

You should see the AI respond with Red Hat-specific knowledge: UBI9 images,
`InferenceService` CRDs, `ServingRuntime` configurations, certified operators,
and Ansible best practices. This confirms the skills are loaded.

### Updating the skills

```bash
cd rh-demo-agents
git pull
```

Because you used `--link`, the symlinks point directly into the repository.
A `git pull` is all you need -- no re-installation required.

### Uninstalling

```bash
cd rh-demo-agents
./install.sh --uninstall
```

This removes all `rh-*` skills and rules from your `~/.cursor/` directories.

### What is installed

After running the install script, here is what you get:

| Skill | Domain |
|-------|--------|
| `rh-demo-orchestrator` | Coordinates multi-product demo planning and building |
| `rh-openshift-expert` | OCP, Virtualization, Quay, ACM, ACS, monitoring, NetworkPolicy |
| `rh-openshift-ai-expert` | RHOAI 3, vLLM, LlamaStack, Lightspeed, Gen AI Playground |
| `rh-rhel-expert` | RHEL 9, UBI9, Image Builder, System Roles, Edge, Podman |
| `rh-openstack-expert` | RHOSP services, Director, NFVi |
| `rh-ansible-expert` | AAP 2.x, EDA, workflows, awx.awx, ServiceNow integration |
| `rh-middleware-expert` | JBoss EAP, Camel, AMQ, 3scale, SSO, Quarkus, Spring Boot |
| `rh-telco-domain` | NFV, CNF, 5G, vRAN, O-RAN, MEC, SR-IOV, DPDK (cross-cutting) |
| `rh-certified-components` | Catalog of UBI9 images, certified operators, Ansible collections |

| Rule | Scope |
|------|-------|
| `rh-demo-conventions` | Always-on: UBI9, `podman`/`oc`, certified operators, demo structure |

---

## Quick Reference

| Action | Linux | macOS |
|--------|-------|-------|
| Open Settings | `Ctrl+,` | `Cmd+,` |
| Open Command Palette | `Ctrl+Shift+P` | `Cmd+Shift+P` |
| Open Chat Panel | `Ctrl+L` | `Cmd+L` |
| Open Source Control | `Ctrl+Shift+G` | `Cmd+Shift+G` |
| Open Terminal | `` Ctrl+` `` | `` Cmd+` `` |
| Switch AI mode | `Shift+Tab` | `Shift+Tab` |
| Commit staged changes | `Ctrl+Enter` (in Source Control) | `Cmd+Enter` |

---

## Next Steps

- Browse the [README](../README.md) for the full architecture diagram and
  contribution guidelines
- Try planning a demo: switch to **Plan mode**, select **Claude Opus 4.6**,
  and describe the demo you want to build
- Explore your existing projects: open a repo in Cursor, switch to **Ask
  mode**, and ask the AI to explain the architecture
- Share this guide with colleagues and point them to the `rh-demo-agents`
  repository
