# Telco Demo Patterns Reference

Detailed configurations and patterns for telco-focused Red Hat demos.

## PerformanceProfile for Telco Workloads

The `PerformanceProfile` CR is central to telco OCP configurations:

```yaml
apiVersion: performance.openshift.io/v2
kind: PerformanceProfile
metadata:
  name: telco-perf-profile
spec:
  cpu:
    isolated: "2-31,34-63"
    reserved: "0-1,32-33"
  hugepages:
    defaultHugepagesSize: 1G
    pages:
      - size: 1G
        count: 16
        node: 0
  realTimeKernel:
    enabled: true
  numa:
    topologyPolicy: "single-numa-node"
  net:
    userLevelNetworking: true
```

Key fields:
- `isolated`: CPUs for workload (no kernel tasks)
- `reserved`: CPUs for platform (kubelet, CRI-O, kernel)
- `hugepages`: 1G pages for DPDK/VNF memory
- `realTimeKernel`: enables the RT kernel for deterministic latency
- `topologyPolicy`: NUMA-aware scheduling

## SR-IOV Configuration

### Network Node Policy

```yaml
apiVersion: sriovnetwork.openshift.io/v1
kind: SriovNetworkNodePolicy
metadata:
  name: sriov-policy-netdevice
  namespace: openshift-sriov-network-operator
spec:
  nodeSelector:
    node-role.kubernetes.io/worker-cnf: ""
  resourceName: sriov_netdevice
  numVfs: 8
  nicSelector:
    pfNames: ["ens1f0"]
  deviceType: netdevice
```

### SR-IOV Network

```yaml
apiVersion: sriovnetwork.openshift.io/v1
kind: SriovNetwork
metadata:
  name: sriov-net
  namespace: openshift-sriov-network-operator
spec:
  resourceName: sriov_netdevice
  networkNamespace: cnf-demo
  ipam: '{"type": "host-local", "subnet": "10.56.217.0/24"}'
```

### Pod with SR-IOV

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: cnf-workload
  namespace: cnf-demo
  annotations:
    k8s.v1.cni.cncf.io/networks: sriov-net
spec:
  containers:
    - name: cnf
      image: registry.access.redhat.com/ubi9/ubi:latest
      resources:
        requests:
          openshift.io/sriov_netdevice: "1"
        limits:
          openshift.io/sriov_netdevice: "1"
```

## PTP Configuration

```yaml
apiVersion: ptp.openshift.io/v1
kind: PtpConfig
metadata:
  name: grandmaster
  namespace: openshift-ptp
spec:
  profile:
    - name: grandmaster-profile
      interface: "ens1f0"
      ptp4lOpts: "-2"
      phc2sysOpts: "-a -r -n 24"
  recommend:
    - profile: grandmaster-profile
      priority: 10
      match:
        - nodeLabel: "ptp/grandmaster"
```

## 5G Core CNF Deployment Pattern

Typical namespace and resource layout for a 5GC demo:

```
Namespace: 5gc-demo
  |-- Deployment: amf          (SR-IOV, SCTP)
  |-- Deployment: smf          (Multus secondary net)
  |-- Deployment: upf          (SR-IOV + DPDK, hugepages, isolated CPUs)
  |-- Deployment: nrf          (cluster network only)
  |-- Deployment: ausf         (cluster network only)
  |-- Deployment: udm          (cluster network only)
  |-- Deployment: nssf         (cluster network only)
  |-- Service: nrf-sbi         (ClusterIP, port 8080)
  |-- NetworkAttachmentDefinition: n2-network  (SR-IOV, SCTP for N2)
  |-- NetworkAttachmentDefinition: n3-network  (SR-IOV for N3 user plane)
  |-- NetworkAttachmentDefinition: n4-network  (Multus bridge for N4)
  |-- NetworkAttachmentDefinition: n6-network  (SR-IOV for N6 to DN)
```

UPF requires the most tuning:
- Hugepages (1G)
- Isolated CPUs via `PerformanceProfile`
- SR-IOV or DPDK for N3/N6 interfaces
- NUMA-aware placement

## Single-Node OpenShift (SNO) for RAN DU

SNO is the standard platform for far-edge DU workloads:

### ZTP (Zero Touch Provisioning) with ACM

```yaml
apiVersion: ran.openshift.io/v1
kind: SiteConfig
metadata:
  name: cell-site-001
spec:
  baseDomain: telco.example.com
  clusterImageSetNameRef: "openshift-4.16"
  clusters:
    - clusterName: du-site-001
      networkType: OVNKubernetes
      nodes:
        - hostName: du-node
          role: master
          bmcAddress: idrac-virtualmedia+https://192.168.1.10/redfish/v1/Systems/System.Embedded.1
          bmcCredentialsName:
            name: bmc-secret
          bootMACAddress: "AA:BB:CC:DD:EE:FF"
          installerArgs: '["--append-karg", "default_hugepagesz=1G", "--append-karg", "hugepagesz=1G"]'
```

### PolicyGenTemplate for DU Profile

```yaml
apiVersion: ran.openshift.io/v1
kind: PolicyGenTemplate
metadata:
  name: du-profile
spec:
  bindingRules:
    du-profile: "true"
  mcp: "master"
  sourceFiles:
    - fileName: PerformanceProfile.yaml
      policyName: "perf-policy"
    - fileName: SriovNetworkNodePolicy.yaml
      policyName: "sriov-policy"
    - fileName: PtpConfig.yaml
      policyName: "ptp-policy"
    - fileName: TunedPerformancePatch.yaml
      policyName: "tuned-policy"
```

## RHOSP NFVi Configuration

### Compute Node with SR-IOV (Director Template Excerpt)

```yaml
parameter_defaults:
  NeutronMechanismDrivers: ['openvswitch', 'sriovnicswitch']
  NovaPCIPassthrough:
    - vendor_id: "8086"
      product_id: "154c"
      address: "0000:04:00.0"
      physical_network: "sriov-net"
  NovaReservedHostMemory: 4096
  NovaComputeCpuDedicatedSet: "4-43,48-87"
  NovaComputeCpuSharedSet: "0-3,44-47"
  KernelArgs: "default_hugepagesz=1G hugepagesz=1G hugepages=64 iommu=pt intel_iommu=on"
```

### OVS-DPDK Configuration

```yaml
parameter_defaults:
  OvsDpdkCoreList: "0,1,44,45"
  OvsDpdkMemoryChannels: "4"
  OvsDpdkSocketMemory: "4096,4096"
  OvsPmdCoreList: "2,3,46,47"
  NeutronDatapathType: "netdev"
  NeutronVhostuserSocketDir: "/var/lib/vhost_sockets"
```

## Network Automation Patterns

### Ansible Playbook for Router Configuration

```yaml
---
- name: Configure telco router
  hosts: routers
  gather_facts: false
  collections:
    - cisco.ios
    - ansible.netcommon
  tasks:
    - name: Configure BGP
      cisco.ios.ios_bgp_global:
        config:
          as_number: "65001"
          router_id: "10.0.0.1"
          neighbors:
            - neighbor_address: "10.0.0.2"
              remote_as: 65002
              description: "Peer to Core"
        state: merged

    - name: Configure VRF for network slice
      cisco.ios.ios_vrf:
        vrfs:
          - name: slice-embb
            rd: "65001:100"
            route_both: "65001:100"
            description: "eMBB slice VRF"
```

### EDA Rulebook for Network Event Remediation

```yaml
---
- name: Network fault remediation
  hosts: all
  sources:
    - ansible.eda.alertmanager:
        host: 0.0.0.0
        port: 9000
  rules:
    - name: Link down remediation
      condition: event.alerts[0].labels.alertname == "LinkDown"
      action:
        run_playbook:
          name: playbooks/remediate-link-down.yml
          extra_vars:
            affected_host: "{{ event.alerts[0].labels.instance }}"
            interface: "{{ event.alerts[0].labels.interface }}"
```

## Telco Reference Design Specifications

Red Hat publishes Telco RDS documents for validated configurations:

- **Telco RAN DU**: SNO + PerformanceProfile + SR-IOV + PTP + real-time kernel
- **Telco Core**: Compact cluster (3 masters) + SR-IOV + Multus + SCTP
- **Telco RAN CU**: Standard OCP cluster with moderate performance tuning

These are available at:
[OCP Telco Reference Design Specs](https://docs.redhat.com/en/documentation/openshift_container_platform/4.16/html/telco_reference_design_specifications/)

Always align demo configurations with the appropriate RDS profile.
