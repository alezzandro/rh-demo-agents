# Certified Components Catalog

Comprehensive reference of Red Hat certified components for demo use.

## UBI9 Base Images - Full List

### Core Images

| Image | Path | Size | Package Manager | Use Case |
|-------|------|------|-----------------|----------|
| Standard | `registry.access.redhat.com/ubi9/ubi:9.4` | ~215MB | dnf | General purpose, debugging |
| Minimal | `registry.access.redhat.com/ubi9/ubi-minimal:9.4` | ~95MB | microdnf | Production services |
| Micro | `registry.access.redhat.com/ubi9/ubi-micro:9.4` | ~25MB | none | Static binaries, Go apps |
| Init | `registry.access.redhat.com/ubi9/ubi-init:9.4` | ~230MB | dnf + systemd | Multi-process containers |

### Language Runtimes

| Runtime | Path | Notes |
|---------|------|-------|
| Node.js 18 | `registry.access.redhat.com/ubi9/nodejs-18` | LTS |
| Node.js 20 | `registry.access.redhat.com/ubi9/nodejs-20` | LTS, preferred |
| Python 3.9 | `registry.access.redhat.com/ubi9/python-39` | |
| Python 3.11 | `registry.access.redhat.com/ubi9/python-311` | Preferred |
| Python 3.12 | `registry.access.redhat.com/ubi9/python-312` | Latest |
| OpenJDK 17 | `registry.access.redhat.com/ubi9/openjdk-17` | LTS |
| OpenJDK 21 | `registry.access.redhat.com/ubi9/openjdk-21` | LTS, preferred |
| Go Toolset | `registry.access.redhat.com/ubi9/go-toolset` | Build stage only |
| .NET 8.0 | `registry.access.redhat.com/ubi9/dotnet-80` | LTS |
| Ruby 3.1 | `registry.access.redhat.com/ubi9/ruby-31` | |
| PHP 8.1 | `registry.access.redhat.com/ubi9/php-81` | |
| Perl 5.32 | `registry.access.redhat.com/ubi9/perl-532` | |

### Infrastructure Images

| Service | Path | Notes |
|---------|------|-------|
| PostgreSQL 15 | `registry.redhat.io/rhel9/postgresql-15` | |
| MySQL 8.0 | `registry.redhat.io/rhel9/mysql-80` | |
| MariaDB 10.5 | `registry.redhat.io/rhel9/mariadb-105` | |
| Redis 6 | `registry.redhat.io/rhel9/redis-6` | |
| Nginx 1.22 | `registry.redhat.io/ubi9/nginx-122` | |
| Apache httpd | `registry.redhat.io/ubi9/httpd-24` | |

## S2I (Source-to-Image) Builder Images

For OpenShift builds:

| Builder | Path |
|---------|------|
| Node.js 20 | `registry.redhat.io/ubi9/nodejs-20-minimal` |
| Python 3.11 | `registry.redhat.io/ubi9/python-311` |
| OpenJDK 17 | `registry.redhat.io/ubi9/openjdk-17` |
| .NET 8.0 | `registry.redhat.io/ubi9/dotnet-80` |
| Go | `registry.redhat.io/ubi9/go-toolset` |

## Red Hat Operator Catalog

Operators from the `redhat-operators` CatalogSource, grouped by category:

### Platform Services

| Operator | Package Name | Default Namespace |
|----------|-------------|-------------------|
| OpenShift Pipelines | `openshift-pipelines-operator-rh` | `openshift-pipelines` |
| OpenShift GitOps | `openshift-gitops-operator` | `openshift-gitops` |
| OpenShift Serverless | `serverless-operator` | `openshift-serverless` |
| OpenShift Service Mesh | `servicemeshoperator` | `openshift-operators` |
| OpenShift Virtualization | `kubevirt-hyperconverged` | `openshift-cnv` |

### Networking

| Operator | Package Name | Default Namespace |
|----------|-------------|-------------------|
| SR-IOV Network Operator | `sriov-network-operator` | `openshift-sriov-network-operator` |
| PTP Operator | `ptp-operator` | `openshift-ptp` |
| MetalLB | `metallb-operator` | `metallb-system` |
| NMState | `kubernetes-nmstate-operator` | `openshift-nmstate` |

### Security and Compliance

| Operator | Package Name | Default Namespace |
|----------|-------------|-------------------|
| ACS (StackRox) | `rhacs-operator` | `stackrox` |
| Compliance Operator | `compliance-operator` | `openshift-compliance` |
| File Integrity Operator | `file-integrity-operator` | `openshift-file-integrity` |
| Cert Manager | `openshift-cert-manager-operator` | `cert-manager` |

### Storage

| Operator | Package Name | Default Namespace |
|----------|-------------|-------------------|
| ODF (OpenShift Data Foundation) | `odf-operator` | `openshift-storage` |
| LVM Storage | `lvms-operator` | `openshift-storage` |

### Observability

| Operator | Package Name | Default Namespace |
|----------|-------------|-------------------|
| Loki Operator | `loki-operator` | `openshift-operators-redhat` |
| Tempo Operator | `tempo-product` | `openshift-tempo-operator` |
| Cluster Observability | `cluster-observability-operator` | `openshift-operators` |

### Middleware

| Operator | Package Name | Default Namespace |
|----------|-------------|-------------------|
| AMQ Streams | `amq-streams` | user namespace |
| AMQ Broker | `amq-broker-rhel8` | user namespace |
| Red Hat SSO / Keycloak | `rhbk-operator` | user namespace |
| 3scale | `3scale-operator` | user namespace |
| JBoss EAP | `eap` | user namespace |
| Camel K | `red-hat-camel-k` | user namespace |
| Fuse Online | `fuse-online` | user namespace |

### Multi-Cluster

| Operator | Package Name | Default Namespace |
|----------|-------------|-------------------|
| ACM | `advanced-cluster-management` | `open-cluster-management` |
| Submariner | `submariner` | `submariner-operator` |

### AI / ML

| Operator | Package Name | Default Namespace |
|----------|-------------|-------------------|
| OpenShift AI (RHOAI) | `rhods-operator` | `redhat-ods-operator` |
| OpenShift Lightspeed | `lightspeed-operator` | `openshift-lightspeed` |
| NVIDIA GPU Operator | `gpu-operator-certified` | `nvidia-gpu-operator` |
| Node Feature Discovery | `nfd` | `openshift-nfd` |
| Intel Gaudi Operator | `habana-ai-operator` | `habana-ai-operator` |

### Registry

| Operator | Package Name | Default Namespace |
|----------|-------------|-------------------|
| Quay | `quay-operator` | `quay-enterprise` |

## Ansible Certified Collections

Available from Automation Hub (`console.redhat.com/ansible/automation-hub`):

### Red Hat Collections

| Collection | Version | Purpose |
|------------|---------|---------|
| `redhat.rhel_system_roles` | 1.x | RHEL system configuration |
| `redhat.openshift` | 2.x | OpenShift cluster management |
| `redhat.satellite` | 3.x | Satellite/Foreman management |
| `redhat.insights` | 1.x | Red Hat Insights integration |
| `redhat.runtimes` | 1.x | Middleware deployment |

### Kubernetes / Cloud

| Collection | Purpose |
|------------|---------|
| `kubernetes.core` | Core K8s resource management |
| `amazon.aws` | AWS cloud provider |
| `google.cloud` | GCP cloud provider |
| `azure.azcollection` | Azure cloud provider |
| `openstack.cloud` | OpenStack provider |
| `vmware.vmware_rest` | VMware management |

### ITSM / ServiceNow

| Collection | Purpose |
|------------|---------|
| `servicenow.itsm` | Incident, change, CMDB management |

### AAP Management

| Collection | Purpose |
|------------|---------|
| `awx.awx` | Controller objects as code (credentials, projects, workflows) |

### Network

| Collection | Purpose |
|------------|---------|
| `ansible.netcommon` | Network abstraction layer |
| `ansible.utils` | Network utilities |
| `cisco.ios` | Cisco IOS devices |
| `cisco.nxos` | Cisco NX-OS (Nexus) |
| `cisco.aci` | Cisco ACI fabric |
| `junipernetworks.junos` | Juniper devices |
| `arista.eos` | Arista switches |
| `f5networks.f5_modules` | F5 load balancers |
| `paloaltonetworks.panos` | Palo Alto firewalls |

## Execution Environment Base Images

For building Ansible Execution Environments:

| Image | Path | Purpose |
|-------|------|---------|
| EE Minimal | `registry.redhat.io/ansible-automation-platform-25/ee-minimal-rhel9` | Lightweight EE |
| EE Supported | `registry.redhat.io/ansible-automation-platform-25/ee-supported-rhel9` | With certified collections |
| Ansible Builder | `registry.redhat.io/ansible-automation-platform-25/ansible-builder-rhel9` | Build tool |

## Registry Access

### No Authentication Required

- `registry.access.redhat.com` -- UBI images, public content

### Authentication Required

- `registry.redhat.io` -- Product images, requires Red Hat account
- Configure with: `podman login registry.redhat.io`
- For OCP: create a pull secret in `openshift-config` namespace

### Registry Catalog

Browse all certified images at:
- [Red Hat Container Catalog](https://catalog.redhat.com/software/containers/search)
- [Red Hat Ecosystem Catalog](https://catalog.redhat.com/)
