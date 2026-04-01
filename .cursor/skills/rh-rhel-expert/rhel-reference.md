# RHEL detailed reference (rh-rhel-expert)

Official narrative and version-specific behavior should always be verified against [RHEL 9 documentation](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/9/).

---

## RHEL 9 architecture and lifecycle

- **Architecture**: Same general userspace as Fedora lineage but with **enterprise kernel**, **backports**, **extended support**, and **certified ecosystem** (hardware, software, cloud).
- **Major/minor**: Major releases (e.g. 9) bring larger platform shifts; minors add features and hardware enablement on a cadence documented in RHEL release notes.
- **Lifecycle**: Full Support, Maintenance Support, and Extended Life phases—plan demos to mention support phase when discussing patching SLAs.
- **Streams**: Application Streams and modules provide newer language/runtimes without changing the major platform base; see module documentation for `dnf module` workflows.

---

## UBI 9 image variants

**Registries**

- `registry.access.redhat.com/ubi9/ubi`
- `registry.access.redhat.com/ubi9/ubi-minimal`
- `registry.access.redhat.com/ubi9/ubi-micro`
- `registry.access.redhat.com/ubi9/ubi-init`

**Authenticated pulls** (e.g. for some content): `registry.redhat.io` with registry credentials—see [Red Hat Container Registry](https://access.redhat.com/registry) and your subscription terms.

| Variant | Typical use |
|---------|-------------|
| **ubi** | General apps; `dnf`/`yum`-style workflows; more libraries preinstalled. |
| **ubi-minimal** | Smaller attack surface; `microdnf`; good for microservices with few packages. |
| **ubi-micro** | Extremely small; **no package manager** in the final image—copy binaries from builder stage. |
| **ubi-init** | **systemd** as init; multi-service containers or demos needing journald/service units. |

Docs: [Types of UBI images](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/9/html/building_running_and_managing_containers/assembly_types-of-ubi-images) (RHEL 9 — Building, running, and managing containers).

---

## Image Builder

**Docs**: [Composing a RHEL image using Image Builder](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/9/html/composing_a_rhel_image_using_image_builder/index)

### composer-cli (common commands)

- `composer-cli blueprints list`
- `composer-cli blueprints show BLUEPRINT`
- `composer-cli blueprints push FILE.toml`
- `composer-cli compose start BLUEPRINT IMAGE_TYPE`
- `composer-cli compose list`
- `composer-cli compose status UUID`
- `composer-cli compose logs UUID`
- `composer-cli compose image UUID`

Exact **IMAGE_TYPE** strings depend on installed plugins and version; common examples include **`qcow2`**, **`ami`**, **`installer`**, **`edge-commit`**, **`edge-container`**—confirm with `composer-cli compose types` on the build host.

### Blueprint format (conceptual)

- TOML (or JSON via API) defines **packages**, **modules**, **groups**, **customizations** (users, SSH keys, firewall, services, filesystem layout where supported).
- Version the blueprint in Git for “infrastructure as definition” demos.

### Output types (typical)

| Type | Role |
|------|------|
| **qcow2** | KVM/QEMU, OpenStack, generic VM disk. |
| **ami** | AWS machine images (workflow may include upload helpers). |
| **iso** / **installer** | Bare metal / VM install media. |
| **edge-commit** | OSTree commit for RHEL for Edge. |
| **edge-container** | Containerized transport of edge payload (see Edge docs for deployment pattern). |

---

## RHEL System Roles (representative list)

**Docs**: [Automating system administration by using RHEL System Roles](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/9/html/automating_system_administration_by_using_rhel_system_roles/index)

Roles ship in supported Ansible collections; names evolve—use `ansible-doc` / collection docs on the control node. Commonly demonstrated roles include:

| Area | Example roles / topics |
|------|-------------------------|
| Network | `network` (NetworkManager, bonds, bridges) |
| Time | `timesync` (chrony/NTP alignment) |
| SELinux | `selinux` (mode, booleans, ports) |
| Crypto | `crypto_policies` |
| Firewall | `firewall` |
| Storage | `storage` (LVM, Stratis-related demos as supported) |
| HA / cluster | `ha_cluster` (where licensed/supported for the scenario) |
| VPN / IPsec | `vpn`, `ipsec` |
| Logging / metrics | `logging`, `metrics` |
| Postfix / Mail | `postfix` |
| Snapshot / backup hooks | `snapshot` (see role docs for RHEL version support) |

Always pin collection versions in demos that imply supportability.

---

## RHEL for Edge

**Docs**: [Composing, installing, and managing RHEL for Edge images](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/9/html/composing_installing_and_managing_rhel_for_edge_images/index)

### rpm-ostree (common commands)

- `rpm-ostree status`
- `rpm-ostree upgrade`
- `rpm-ostree deploy REV`
- `rpm-ostree rebase REF`
- `rpm-ostree rollback`
- `rpm-ostree install PACKAGE` (layered packages—understand persistence vs tree updates)

### greenboot

- Health check scripts under **`/etc/greenboot/check/required.d`** and **`.../wanted.d`** (paths may vary slightly by version—confirm in docs).
- Used to **validate** networking, services, or custom probes after boot; failures can drive **rollback** stories when combined with rpm-ostree design.

### OSTree repo management (high level)

- Serve commits over **HTTP(S)** for clients to pull.
- Image Builder produces **edge** artifacts; automation often mirrors repo layout to a web server or object storage fronted by TLS.

---

## Podman

**Docs**: [Building, running, and managing containers](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/9/html/building_running_and_managing_containers/index)

### Key commands

- `podman run`, `podman ps`, `podman logs`, `podman exec`
- `podman build` (Buildah-backed)
- `podman pod create`, `podman pod start|stop`
- `podman generate systemd` (legacy helper vs Quadlet preference in new demos)
- `podman login registry.redhat.io`

### Quadlet

- Files: **`*.container`**, **`*.pod`**, **`*.volume`**, **`*.kube`** under **`~/.config/containers/systemd/`** (user) or **`/etc/containers/systemd/`** (system).
- `systemctl --user daemon-reload` / `systemctl daemon-reload` then enable generated units.

### systemd integration

- **linger** (`loginctl enable-linger user`) for user services that must run without login.
- Rootless: user systemd + Podman socket activation patterns as documented for the RHEL minor in use.

---

## Cockpit

**Docs**: [Managing systems using the RHEL 9 web console](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/9/html/managing_systems_using_the_rhel_9_web_console/index)

### Enabling

- Install `cockpit` and desired subpackages (e.g. `cockpit-storaged`, `cockpit-networkmanager`, `cockpit-packagekit`).
- `systemctl enable --now cockpit.socket`
- Default port **9090** (adjust firewall role or `firewall-cmd` accordingly).

### Modules

- Optional **Cockpit** pages come from subpackages; install only what the demo needs.
- **Remote management**: browser to `https://HOST:9090` with TLS; combine with SSO/IdP only via supported integrations (demo clearly labeled).

---

## Subscription management

**Portal / product**: [Red Hat Subscription Management](https://access.redhat.com/products/red-hat-subscription-management)

### subscription-manager (common)

- `subscription-manager register --username USER --password PASS`
- `subscription-manager attach --auto` (classic entitlement flows)
- `subscription-manager list --available`
- `subscription-manager repos --list`
- `subscription-manager repos --enable REPO_ID`
- `subscription-manager status`
- `subscription-manager unregister`

### SCA (Simple Content Access)

- Many accounts use **SCA**: simplified access to content without per-system attach in some cases; still document compliance and image build practices.
- For demos, state whether the scenario is **SCA** or **classic** to avoid confusion.

---

## Security

### crypto-policies

- System-wide cryptographic defaults: `update-crypto-policies --set DEFAULT|FIPS|...`
- Applications must be compatible with the selected policy (especially **FIPS**).

### FIPS

- Enable **FIPS mode** at install time or via documented conversion procedures (destructive implications—read RHEL security docs before demo scripts).
- Pair with **FIPS-enabled containers** only when the base image and runtime support the mode.

### SELinux

- `getenforce`, `sestatus`, `ausearch`, `audit2allow` (troubleshooting only).
- Prefer **enforcing**; use **permissive** only for targeted diagnosis.

### Audit

- `auditd` rules; `ausearch -m avc`, `aureport` for compliance narratives.

### AIDE

- File integrity monitoring; initialize database after golden build, schedule checks, integrate with alerting in security demos.

---

## Further reading

- Security hardening: [Security hardening](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/9/html/security_hardening/index) (RHEL 9)
- OpenSCAP / compliance scanning: see RHEL security collection and SCAP documentation for your minor release.
