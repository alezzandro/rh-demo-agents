---
name: rh-rhel-expert
description: Use when planning or building demos involving Red Hat Enterprise Linux, system configuration, container base images, UBI, edge computing, or OS-level features. The agent should apply this skill for RHEL 9 platform guidance, UBI9 base selection, Image Builder workflows, RHEL System Roles, RHEL for Edge, Podman, Cockpit, subscriptions, and OS security patterns. For exact UBI image names and certified-component choices, cross-check the rh-certified-components skill; for deep command syntax, read rhel-reference.md in this folder.
---

# Red Hat Enterprise Linux (RHEL) expert skill

Use this skill when demos need **RHEL 9** as the operating system story: bare metal, VMs, edge devices, or **UBI9**-based containers. Prefer **Red Hat UBI 9** over community base images when a UBI equivalent exists (see project conventions and **rh-certified-components**).

## RHEL 9 at a glance

- **Platform**: Long-life enterprise Linux with predictable lifecycle (major releases ~every 3 years; RHEL 9 is the current major for many demos as of common deployments in 2025–2026).
- **Differentiators for demos**: Image Builder for reproducible gold images; **ansible-based RHEL System Roles** for consistent configuration; **RHEL for Edge** with **rpm-ostree** and **greenboot**; **Podman** for rootless containers and systemd-friendly workloads; **Cockpit** for browser-based administration.

## UBI 9 images

| Image | Role |
|-------|------|
| **ubi9/ubi** | Full UBI; general-purpose apps needing more packages and shell tooling. |
| **ubi9/ubi-minimal** | Smaller runtime; `microdnf`; good for services with fewer dependencies. |
| **ubi9/ubi-micro** | Minimal userspace; no package manager in image; supply artifacts via multi-stage copy. |
| **ubi9/ubi-init** | `systemd` as PID 1; suitable when the demo needs service units inside the container. |

Registry: `registry.access.redhat.com` or `registry.redhat.io` (authenticated). Exact tags and certification notes: **rh-certified-components** skill.

## Image Builder (composer-cli)

- **composer-cli** drives **lorax-composer** / osbuild-backed pipelines from the shell or automation.
- **Blueprint**: TOML/JSON description of packages, users, services, and customizations; compose into **image types** (qcow2, AMI, installer ISO, **edge-commit**, etc.).
- Use Image Builder when the demo is “golden image factory” or “compliance-ready image from definition.”

## RHEL System Roles (Ansible)

Red Hat ships **ansible collections** with supported roles for common configuration (network, time, SELinux, crypto policies, firewall, storage, and more). Demos show **idempotent**, **auditable** system state driven from Ansible Automation Platform or ad hoc playbooks.

## RHEL for Edge

- **rpm-ostree**: immutable/transactional updates; `rpm-ostree status`, `upgrade`, `rebase`.
- **greenboot**: health checks after boot; failed checks can trigger rollback semantics in edge designs.
- **OSTree repo**: hosts commits consumed by edge clients; pairs with Image Builder **edge-commit** / edge installer flows.

## Podman

- **Rootless**: user namespaces; no daemon; maps well to least-privilege demos.
- **Pods**: `podman pod` groups containers sharing network namespace.
- **Quadlet** (`.container`, `.pod`, `.volume`, `.kube` under `~/.config/containers/systemd/` or `/etc/containers/systemd/`): declarative units that **systemd** can generate and manage.

## Cockpit (RHEL web console)

Browser UI for storage, networking, services, updates, metrics, and (with modules) specialized tasks. Enable with `cockpit.socket`; often used for **remote** administration demos alongside SSH.

---

## Quick reference: RHEL components

| Component | Purpose | Example demo scenarios |
|-----------|---------|-------------------------|
| RHEL 9 | Stable enterprise OS for apps and infra | “Lift-and-shift” app on RHEL; baseline security posture |
| UBI 9 | Redistributable container base aligned with RHEL | Multi-stage build; FIPS-friendly container story |
| Image Builder | Composed OS images from blueprints | Pipeline from blueprint → qcow2/AMI/ISO/edge |
| System Roles | Supported Ansible roles for RHEL config | Firewall + SELinux + time sync from one playbook |
| RHEL for Edge | OSTree-based edge images + health | Field device update; greenboot rollback narrative |
| Podman | Daemonless containers, pods, Quadlet | Rootless service container; pod as a “logical host” |
| Cockpit | Web console for single-host ops | Operator dashboard; storage/network troubleshooting UI |
| subscription-manager | Entitlements and repo access | SCA vs classic; `attach` / repo enablement demos |

---

## Common demo patterns

1. **Custom RHEL image pipeline** — Author a **blueprint**, run **composer-cli** composes, publish **qcow2** or **AMI**, optionally add **kickstart** or edge outputs.
2. **Edge device management** — Build **edge-commit**, serve **OSTree** repo, **rpm-ostree** upgrade on device, **greenboot** validates services after boot.
3. **Rootless container workloads** — **Podman** as non-root, **Quadlet** + **systemd** user linger, optional **pod** for sidecars.
4. **System hardening with System Roles** — Playbooks applying **selinux**, **firewall**, **crypto_policies**, **timesync**, **storage** roles for a repeatable hardened baseline.

---

## Best practices

- Run **SELinux in enforcing** mode unless the demo explicitly showcases permissive troubleshooting.
- When regulations apply, design for **FIPS-enabled** RHEL and document **crypto-policies** implications for apps and containers.
- Use **subscription-manager** (or **Simple Content Access** where appropriate) so repos and support alignment match the customer narrative; avoid implying unsupported repo mixes.
- Prefer **UBI 9** for containerized applications in Red Hat–aligned demos; validate image choice against **rh-certified-components**.

---

## Documentation references (official)

- RHEL 9 product documentation hub: https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/9/
- Composing images with Image Builder: https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/9/html/composing_a_rhel_image_using_image_builder/index
- Automating administration with RHEL System Roles: https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/9/html/automating_system_administration_by_using_rhel_system_roles/index
- RHEL for Edge (compose, install, manage): https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/9/html/composing_installing_and_managing_rhel_for_edge_images/index
- Building, running, and managing containers (Podman, UBI): https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/9/html/building_running_and_managing_containers/index
- Managing systems with the RHEL 9 web console (Cockpit): https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/9/html/managing_systems_using_the_rhel_9_web_console/index
- Subscription management (Customer Portal): https://access.redhat.com/products/red-hat-subscription-management

## Companion files

- **rhel-reference.md** — Command-level detail for Image Builder, System Roles names, Edge/Podman/Cockpit, subscriptions, and security tooling.
- **rh-certified-components** skill — Use for certified/UBI image selection and catalog-aligned choices.
