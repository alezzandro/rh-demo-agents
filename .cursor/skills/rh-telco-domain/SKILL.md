---
name: rh-telco-domain
description: >-
  Use when planning or building demos for telecommunications customers, or when
  the demo involves NFV, CNF, 5G core, RAN, vRAN, O-RAN, MEC, network slicing,
  or telco-specific infrastructure configurations.
---

# Red Hat Telco Domain

Cross-cutting telco knowledge that augments the product-specific domain expert
skills. This skill provides telecommunications industry context, telco-specific
Red Hat product configurations, and common telco demo patterns.

## Overview

Telco demos typically involve multiple Red Hat products configured with
telco-specific optimizations. This skill does NOT replace the domain experts --
it provides the telco lens through which their output should be filtered.

When this skill is active, ensure that every domain expert subagent also
receives telco context and constraints.

## Telco Architecture Layers

| Layer | Description | Red Hat Products |
|-------|-------------|-----------------|
| NFVi / CaaS | Infrastructure hosting VNFs/CNFs | RHOSP, OpenShift |
| VNF / CNF | Network functions (virtualized or containerized) | OCP workloads, RHOSP VMs |
| MANO / Orchestration | Lifecycle management of network functions | Ansible, ACM, GitOps |
| Service Layer | End-to-end service composition | Middleware, Camel, AMQ |
| Operations | Monitoring, automation, Day-2 | Ansible, EDA, OCP observability |

## Key Telco Concepts

### NFV vs CNF

- **VNF** (Virtual Network Function): runs as a VM on RHOSP/OpenShift Virtualization
- **CNF** (Cloud-native Network Function): runs as containers on OpenShift
- Telco industry is migrating VNF to CNF; demos should show both where relevant

### 5G Architecture

- **5G Core (5GC)**: UPF, SMF, AMF, NRF, NSSF, AUSF, UDM -- microservices-based
- **RAN**: gNodeB (distributed or centralized), O-RAN split (CU/DU/RU)
- **MEC**: Multi-access Edge Computing -- workloads at the edge, close to RAN

### O-RAN and vRAN

- O-RAN Alliance defines open interfaces between RAN components
- vRAN: virtualized RAN running CU/DU on COTS hardware with OpenShift
- Near-RT RIC and Non-RT RIC for RAN intelligent control
- Red Hat provides the platform (OCP) for DU workloads with real-time kernel

## Telco-Specific OCP Configurations

Critical for any OpenShift-based telco demo:

| Feature | Purpose | OCP Configuration |
|---------|---------|-------------------|
| Real-time kernel | Deterministic latency for DU | `MachineConfig` with rt-kernel, `PerformanceProfile` |
| SR-IOV | Hardware-accelerated networking | SR-IOV Network Operator, `SriovNetworkNodePolicy` |
| DPDK | Userspace packet processing | OVS-DPDK or app-level DPDK with hugepages |
| PTP (IEEE 1588) | Time synchronization for RAN | PTP Operator, `PtpConfig` |
| NUMA-aware scheduling | CPU/memory locality | Topology Manager, `PerformanceProfile` |
| Hugepages | Large memory pages for VNFs/CNFs | `PerformanceProfile`, pod requests |
| CPU isolation | Dedicated CPUs for workload | `PerformanceProfile` reserved/isolated CPUs |
| SCTP | Signaling transport | Enabled via `MachineConfig` |

## Common Demo Patterns

### 1. 5G Core on OpenShift

Deploy 5GC network functions as CNFs on OCP with telco optimizations.

- Products: OpenShift, ACM (multi-site), Ansible (Day-2)
- Key features: SR-IOV, Multus, SCTP, service mesh for 5GC SBI

### 2. vRAN / O-RAN DU on OpenShift

Run Distributed Unit workloads on single-node OpenShift (SNO) at cell sites.

- Products: OpenShift (SNO), ACM (fleet management), GitOps
- Key features: Real-time kernel, PTP, SR-IOV, CPU isolation, hugepages

### 3. NFV Infrastructure with RHOSP

Classical NFVi for VNF workloads on OpenStack.

- Products: RHOSP, RHEL, Ansible
- Key features: SR-IOV, OVS-DPDK, CPU pinning, NUMA, hugepages

### 4. Telco Edge with MEC

Deploy edge applications close to the RAN for low-latency services.

- Products: OpenShift (SNO or 3-node), ACM, Ansible
- Key features: Remote worker nodes, edge GitOps, intermittent connectivity

### 5. Network Automation with Ansible

Automate network device configuration and service provisioning.

- Products: AAP, EDA, network collections (Cisco, Juniper, Arista)
- Key features: Network resource modules, NETCONF/RESTCONF, EDA for events

## Best Practices for Telco Demos

- Always show the performance profile and tuning (audiences expect it)
- Demonstrate Day-2 operations, not just Day-0/Day-1 deployment
- Show multi-site management with ACM for RAN/edge scenarios
- Use GitOps (OpenShift GitOps / Argo CD) for fleet-scale configuration
- Include observability (metrics, alerts, dashboards) -- telco buyers need it
- Reference 3GPP and O-RAN standards when relevant

## Documentation References

- [OCP for Telco](https://docs.redhat.com/en/documentation/openshift_container_platform/4.16/html/telco_reference_design_specifications/)
- [SR-IOV Network Operator](https://docs.redhat.com/en/documentation/openshift_container_platform/4.16/html/networking/hardware-networks)
- [PTP Operator](https://docs.redhat.com/en/documentation/openshift_container_platform/4.16/html/networking/ptp)
- [Performance Addon Operator](https://docs.redhat.com/en/documentation/openshift_container_platform/4.16/html/scalability_and_performance/)
- [ACM](https://docs.redhat.com/en/documentation/red_hat_advanced_cluster_management_for_kubernetes/)
- [RHOSP NFV](https://docs.redhat.com/en/documentation/red_hat_openstack_platform/17.1/html/network_functions_virtualization_planning_and_configuration_guide/)

For detailed telco demo patterns and configurations, see [telco-patterns.md](telco-patterns.md).
