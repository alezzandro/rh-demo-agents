# Red Hat OpenStack Platform — detailed reference

Companion to [SKILL.md](SKILL.md). Use for architecture, Director mechanics,
service depth, NFVi, OpenShift integration, CLI patterns, and demo
troubleshooting.

---

## RHOSP architecture: undercloud and overcloud

**Undercloud**

- A single (or HA) management stack that runs **TripleO** tooling: **undercloud.conf**,
  containerized OpenStack services used only to deploy the overcloud, **Ironic**
  for introspection and deployment of overcloud nodes, **Heat** to apply the
  overcloud stack, and **Ansible** for post-configuration.
- Operators interact from the undercloud with **`openstack overcloud deploy`**
  (and related commands), passing **roles**, **network configs**, and
  **environment files**.

**Overcloud**

- The tenant-facing cloud: **Controllers** (API, DB, Rabbit, HAProxy, etc.),
  **Computes**, and optional **storage** or **networker** roles depending on the
  composable role layout.
- **High availability** is typically Pacemaker/Corosync-based for stateful
  control services, with load-balanced API endpoints.

**Demo talking points**

- Separation of **day-0/day-1** (Director) vs **day-2** (scale-out, minor
  updates, Ceph expansion) matches customer operations stories.
- Changes flow through **Heat stack updates** and **container image** updates
  rather than hand-editing config on individual controllers in supported flows.

---

## Director deployment: templates, environment files, roles

**Templates**

- **roles_data** — Defines which services run on which named roles (e.g.
  Controller, ComputeHCI). Composable services attach to roles.
- **nic-configs** — Heat templates (often per-role) describing how interfaces map
  to bridges, bonds, VLANs, and provider/tenant traffic.
- **network-environment** (or equivalent) — MTUs, VIPs, allocation pools,
  external resource mappings.

**Environment files (`-e`)**

- YAML snippets merged into the deployment Heat stack: **TLS everywhere**,
  **NTP**, **DNS**, **Ceph** integration, **Octavia** network attachment,
  **Ironic** cleaning options, **NFVi** compute parameters, etc.
- Custom **`parameter_defaults`** override defaults from roles and services.

**Roles**

- **Composable roles** allow splitting network nodes, storage nodes, or edge
  computes without a monolithic “everything on controller” design.
- **Flavor** and **capacity** demos tie to how many nodes of each role exist and
  how **scheduler** and **placement** see aggregates.

**Repeatability**

- Keep a **version-controlled** set of environment files and nic templates;
  document which **container image tags** or **RHOSP version** the bundle targets.

---

## Core services (detail)

### Nova: flavors and scheduling

- **Flavors** define vCPU, RAM, disk (ephemeral), and optional **extra specs**
  (e.g. `hw:cpu_policy=dedicated`, `hw:numa_nodes`, `resources:VGPU`, PCI passthrough
  hints for SR-IOV).
- **Host aggregates** and **availability zones** group hypervisors for features
  (e.g. “DPDK computes”, “SR-IOV rack”).
- **Placement** service backs resource class and trait scheduling (inventory
  for VFs, bandwidth, etc., when configured).

**Demo workflows**

- `openstack flavor list`, `openstack flavor show`, create a custom flavor with
  extra specs for NFVi.
- Show **server create** with **scheduler hints** or **AZ** selection.

### Neutron: networking

**Provider networks**

- Map to physical segments (VLAN, flat); often used for **floating IP**
  external access, **BGP**, or **NFVi** provider L2 domains.

**Tenant networks**

- Typically **VXLAN** or **Geneve** overlay; **L3** via tenant routers and
  **SNAT**; **security groups** as stateful firewalling.

**SR-IOV**

- **Physnet** to **sriov** mechanism driver mapping; **PCI whitelisting** on
  compute; Neutron **port** with **vnic_type=direct** or **macvtap** depending
  on design; Nova flavor / image metadata alignment.

**OVS-DPDK**

- DPDK **hugepages**, **isolcpus**, **OVS** bridge in userspace mode; reduced
  kernel dataplane for selected bridges; careful **MTU** and **CPU** layout vs
  kernel OVS on the same host.

### Cinder: backends

- **Volume types** expose QoS, replication, and backend selection.
- Common backends: **Ceph RBD**, **NFS**, **iSCSI** arrays; demos often show
  **multi-backend** with type selection.
- **Snapshots**, **clones**, and **encrypted volumes** (key manager integration)
  are common customer questions.

### Glance: image management

- **Formats**: raw, qcow2 (common for demos), others per hypervisor needs.
- **Visibility**: public, private, shared; **properties** for scheduling
  (e.g. hw_disk_bus, img_config_drive).
- **Interlock** with **Ironic** for deploy kernels/ramdisks and instance images.

---

## Heat orchestration

**HOT structure**

- **`heat_template_version`**, **`description`**, **`parameters`**,
  **`resources`**, **`outputs`**.
- Use **`type: OS::Heat::Stack`** for **nested stacks** (modular network,
  app tier, LB).

**Resource types**

- Native OpenStack: **`OS::Nova::Server`**, **`OS::Neutron::Net`**, **`OS::Neutron::Subnet`**,
  **`OS::Neutron::Router`**, **`OS::Neutron::FloatingIP`**, **`OS::Cinder::Volume`**,
  **`OS::Octavia::LoadBalancer`** (or versioned equivalents per RHOSP release),
  **`OS::Glance::Image`** (where supported).

**Patterns**

- **Parameters** for image ID, flavor, keypair, external network ID — keeps one
  template portable across labs.
- **Conditions** and **`get_param`** / **`get_attr`** for wiring outputs (e.g.
  LB VIP) into DNS or monitoring demos.

---

## NFVi configuration

**Hugepages**

- Kernel boot params and/or **DPDK** config: reserve **2M** or **1G** pages;
  align **Nova** flavor **mem_page_size** with host reservation.

**CPU pinning and isolation**

- **`isolcpus`**, **`nohz_full`**, **`rcu_nocbs`** (site-specific); **Nova**
  **`vcpu_pin_set`**, **`dedicated_cpus`**, flavor **`hw:cpu_policy`** for
  dedicated CPUs.

**NUMA topology**

- **`hw:numa_nodes`**, **`hw:numa_cpus`**, **`hw:numa_mem`** on flavors; host
  **NUMA** layout must match expected VNF requirements.

**SR-IOV VFs**

- BIOS **SR-IOV** enable; **IOMMU**; **sriov_numvfs**; Neutron **mechanism**
  drivers and **pci_passthrough_whitelist** on compute.

**DPDK poll-mode drivers**

- **PMD** bound to VFIO-PCI or UIO; **OVS-DPDK** `other_config` for socket-mem,
  core masks; validate **MTU** end-to-end (VM, vSwitch, physical).

**Demo caution**

- NFVi labs break easily from **BIOS**, **kernel cmdline**, or **NIC firmware**
  mismatches — script prechecks and document **minimum hardware**.

---

## Integration patterns

### OpenShift on RHOSP

- **IPI**: installer creates networks, machines, and LB resources via OpenStack
  APIs (requires proper **quotas**, **external network**, **API/access** URLs).
- **UPI**: user supplies infrastructure; **machine** objects or manual nodes;
  same **cloud credentials** concept for storage/LB operators.
- Align **MTU** and **DNS** with Neutron and external DNS for a smooth bootstrap.

### Kuryr CNI

- Maps **Kubernetes** namespaces/services to **Neutron** networks and ports;
  reduces encapsulation stacking in some designs; requires coherent **subnet**
  pools and **Octavia** (or other) dependencies per architecture guide.

### Load balancing with Octavia

- **Amphora** lifecycle (VM or container amphora per major version); **listener**,
  **pool**, **member** health monitors; **TLS** termination with **Barbican**
  references for certificates.

---

## CLI reference: demo-oriented `openstack` commands

Authentication (typical):

```bash
source ~/overcloudrc   # or project-specific clouds.yaml / OS_*
```

Identity and scope:

```bash
openstack project list
openstack user list
openstack application credential create ...
```

Compute:

```bash
openstack flavor list
openstack server list
openstack server create --image ... --flavor ... --network ... ...
openstack console url show <server>
```

Networking:

```bash
openstack network list
openstack subnet list
openstack router list
openstack floating ip list
openstack port list
openstack security group list
openstack security group rule create ...
```

Storage and images:

```bash
openstack volume list
openstack volume create --size ... ...
openstack image list
openstack image show ...
```

Orchestration:

```bash
openstack stack list
openstack stack create -t template.yaml -e env.yaml stack1
openstack stack show stack1
openstack stack delete stack1
```

Load balancing:

```bash
openstack loadbalancer list
openstack loadbalancer show ...
openstack listener list
openstack pool list
```

Bare metal (Ironic, when exposed):

```bash
openstack baremetal node list
openstack baremetal node show ...
```

Shared filesystem (Manila):

```bash
openstack share list
openstack share network list
```

Use **`openstack help <command>`** for subcommands; exact arguments vary slightly
by **RHOSP** major.minor.

---

## Troubleshooting: common demo environment issues

| Symptom | Things to check |
|---------|------------------|
| **VM stuck in BUILD** | Image format/properties, compute **nova-compute** logs, **placement** inventory, **hypervisor** down |
| **No connectivity to VM** | **Security groups**, **router** gateway, **SNAT**, **floating IP** association, **provider** VLAN vs wrong bridge |
| **SR-IOV attach fails** | VF count, **whitelist**, flavor **extra specs**, Neutron **port binding** profile, BIOS/IOMMU |
| **OVS-DPDK performance flat** | **Hugepages**, **CPU isolation**, **PMD** cores vs **Nova** vCPUs overlap, **MTU** mismatch |
| **Cinder attach errors** | **Volume type** vs backend, **multipath**, **libvirt** / **cinder-volume** logs, **AZ** mismatch |
| **Heat stack FAILED** | **`openstack stack failure list`**, resource **show** for nested stacks, **quota** limits |
| **Octavia LB DOWN** | **Management** and **data** networks for amphora, **health monitor**, **member** subnet reachability |
| **Overcloud deploy failure** | **undercloud** `tail -f` on heat/tripleo logs, **validation** playbooks, **nic** template typos, **time sync** |
| **OpenShift install on RHOSP fails** | **External** network name, **DNS**, **flavor** names, **API** floating reachability, **quota** |

**General practices**

- Verify **NTP** on undercloud and overcloud nodes before long demos.
- Capture **`openstack server show`**, **`openstack port show`**, and relevant
  **agent** logs (`neutron-openvswitch-agent`, `nova-compute`) for post-demo
  write-ups.

---

## Official documentation (quick links)

- [Red Hat OpenStack Platform product documentation](https://docs.redhat.com/en/documentation/red_hat_openstack_platform/)
- [Director installation and management](https://docs.redhat.com/en/documentation/red_hat_openstack_platform/latest/html/installing_and_managing_red_hat_openstack_platform_with_director/)
- [NFV documentation index](https://docs.redhat.com/en/documentation/red_hat_openstack_platform/latest/html/network_functions_virtualization/)

When quoting behavior for a specific release, cross-check the **versioned**
documentation tree for that **RHOSP** stream.
