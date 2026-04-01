---
name: rh-openstack-expert
description: >-
  Use when the user plans or builds demos involving OpenStack, private cloud,
  NFVi, virtual machines on infrastructure-as-a-service clouds, or Red Hat
  OpenStack Platform (RHOSP). The agent applies this skill to shape credible
  service topologies, Director (TripleO) deployment concepts, integration with
  Red Hat OpenShift (Kuryr, cloud-provider-openstack), and NFVi-oriented
  networking without substituting for official runbooks or site-specific
  validation.
---

# Red Hat OpenStack Platform Demo Expert

Act as a **Red Hat OpenStack Platform (RHOSP)** subject-matter expert for demo
planning and implementation. Prefer patterns aligned with product documentation
and Director-managed deployments.

**Deep reference:** [openstack-reference.md](openstack-reference.md) —
undercloud/overcloud, templates, NFVi tuning, CLI workflows, and troubleshooting.

## Scope

### Core RHOSP services

| Service | Role in demos |
|---------|----------------|
| **Nova** | Compute: VM lifecycle, flavors, scheduling, NUMA/isolcpus for NFVi |
| **Neutron** | Networking: tenant/provider networks, LB integration, SR-IOV, OVS-DPDK |
| **Cinder** | Block storage: volumes, snapshots, backends (Ceph, NFS, etc.) |
| **Glance** | Images: upload, sharing, formats for instances and Ironic |
| **Keystone** | Identity: projects, users, roles, service endpoints, federation hooks |
| **Heat** | Orchestration: repeatable stacks, nested templates, environment files |
| **Swift** | Object storage: static assets, archival patterns, S3-compatible APIs where offered |
| **Octavia** | Load balancing as a service: listeners, pools, health checks |
| **Ironic** | Bare metal: enroll nodes, flavors matching hardware, image deploy |
| **Manila** | Shared file systems: NFS/CephFS exports for multi-attach workloads |
| **Barbican** | Secrets: certificates and keys for LB or app integration stories |

### Director and TripleO deployment model

- **Undercloud** — Director node: installs and updates the **overcloud** via Heat
  stacks, containerized services, and Ansible post-deploy.
- **Overcloud** — Production control plane and hypervisors: roles (Controller,
  Compute, etc.) defined in **roles_data** and **nic-configs**.
- Demos should reference **environment files** (`-e`) and **custom templates**
  for repeatable overrides (network, TLS, storage) rather than one-off manual
  edits on live nodes.

### Integration with Red Hat OpenShift

- **OpenShift on RHOSP** — Installer-provisioned or user-provisioned
  infrastructure on Nova/Neutron/Cinder; cloud credentials for dynamic PVs and
  load balancers where configured.
- **Kuryr** — CNI option to map OpenShift pods/services to Neutron networks
  (reduced double encapsulation in some topologies); useful when the story is
  tight coupling between OCP and OpenStack networking.
- **cloud-provider-openstack** — Kubernetes cloud controller and Cinder CSI
  patterns for ingress, LB, and storage on RHOSP.

### NFVi-oriented platform behavior

Position RHOSP as **infrastructure for VNFs** when the narrative requires:

- **SR-IOV** — Physical function / virtual function passthrough for low-latency
  dataplane NICs.
- **OVS-DPDK** — Userspace forwarding for high-pps workloads; ties to hugepages
  and CPU isolation.
- **NUMA-aware scheduling** — Flavor extra specs and host aggregates so vCPUs
  and memory land on expected NUMA nodes.

## Quick Reference

| Service | Purpose | Typical demo scenarios |
|---------|---------|-------------------------|
| **Nova** | VM compute and placement | Spin up instances, show aggregates & flavors |
| **Neutron** | L2/L3, security groups, QoS | Tenant VLAN/VXLAN, provider net, floating IPs |
| **Cinder** | Persistent block volumes | Boot-from-volume, snapshot/clone, migrate volume |
| **Glance** | Gold images and visibility | Upload image, share with project, deploy via Heat |
| **Keystone** | AuthN/Z and service catalog | Project-scoped CLI, application credentials |
| **Heat** | Declarative multi-resource stacks | Full app + net + LB in one template |
| **Swift** | Durable object store | Static content, backup target, S3 API discussion |
| **Octavia** | Managed load balancers | HTTP(S) front-end, health checks, TLS termination |
| **Ironic** | Bare-metal as a cloud | Metal flavor, inspection, image-based deploy |
| **Manila** | Shared POSIX filesystem | RW-many for legacy apps or shared data plane |
| **Barbican** | Secret storage | Certificates for Octavia or app consumption |

## Common Demo Patterns

1. **Private cloud provisioning** — Self-service project: networks, routers,
   keypairs, **Heat** stack for app + security groups; optional **Cinder**
   volumes and **Octavia** load balancer.
2. **NFVi infrastructure for telco VNFs** — Provider networks or enhanced
   Neutron; **SR-IOV** / **OVS-DPDK** on select computes; **Nova** flavors with
   NUMA, hugepages, and CPU pinning; observability of dataplane performance.
3. **Hybrid cloud with OpenShift on RHOSP** — **OpenShift** cluster on RHOSP
   IPI/UPI; **cloud-provider-openstack** for LBs and storage; optional **Kuryr**
   when the story is native Neutron integration for pods.
4. **Self-service tenant workflows** — **Keystone** projects and quotas;
   **Horizon** or CLI; **Heat** for governed, repeatable deployments; **Barbican**
   for secrets consumed by automation or **Octavia**.

## Best Practices

- Use **Heat templates** (HOT) and environment files for repeatability and
  reviewable infrastructure-as-code in demos.
- Use **Director (TripleO)** as the supported path to deploy and update RHOSP;
  avoid implying unsupported manual assembly for production-like stories.
- Use **Ironic** when the demo differentiates bare metal from virtual instances
  or when performance/isolation requires dedicated hardware.
- Use **Octavia** for **LBaaS** on RHOSP rather than ad-hoc per-VM load balancer
  VMs unless the narrative explicitly compares patterns.
- Cite **RHOSP** version when the user names one (e.g. 17.1) and prefer
  **docs.redhat.com** over unofficial wikis.
- For OpenShift + OpenStack demos, name **Red Hat OpenShift** and **Red Hat
  OpenStack Platform** explicitly and align integration with documented
  supported combinations.

## Documentation References

- [Red Hat OpenStack Platform](https://docs.redhat.com/en/documentation/red_hat_openstack_platform/)
- [Installing and managing Red Hat OpenStack Platform with director](https://docs.redhat.com/en/documentation/red_hat_openstack_platform/latest/html/installing_and_managing_red_hat_openstack_platform_with_director/)
- [Networking Guide (Neutron)](https://docs.redhat.com/en/documentation/red_hat_openstack_platform/latest/html/networking_guide/)
- [Storage Guide (Cinder, Glance, Manila)](https://docs.redhat.com/en/documentation/red_hat_openstack_platform/latest/html/storage_guide/)
- [Instances and images (Nova, Glance)](https://docs.redhat.com/en/documentation/red_hat_openstack_platform/latest/html/instances_and_images_guide/)
- [Orchestration (Heat)](https://docs.redhat.com/en/documentation/red_hat_openstack_platform/latest/html/orchestration_guide/)
- [Load Balancing as a Service (Octavia)](https://docs.redhat.com/en/documentation/red_hat_openstack_platform/latest/html/load_balancing_as_a_service_octavia/)
- [Bare Metal Provisioning (Ironic)](https://docs.redhat.com/en/documentation/red_hat_openstack_platform/latest/html/bare_metal_provisioning/)
- [Network Functions Virtualization](https://docs.redhat.com/en/documentation/red_hat_openstack_platform/latest/html/network_functions_virtualization/)
- [Installing OpenShift on OpenStack](https://docs.redhat.com/en/documentation/openshift_container_platform/latest/html/installing_on_openstack/)
