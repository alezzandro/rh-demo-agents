---
name: rh-certified-components
description: >-
  Use when selecting container base images, operators, Helm charts, or any
  reusable component for a Red Hat demo. Ensures only certified and supported
  components are used.
---

# Red Hat Certified Components

Enforce the use of Red Hat certified and supported components in every demo.
This skill is a cross-cutting concern -- all domain expert subagents should
reference it when selecting images, operators, or charts.

## Overview

Red Hat certifies components through several programs. Using certified
components ensures demos are representative of production environments and
avoids "works on my laptop" issues.

**Rule: If a certified version exists, use it. No exceptions for demos.**

## Container Base Images

Always use UBI (Universal Base Image) from Red Hat:

| Image | Registry Path | Use Case |
|-------|---------------|----------|
| UBI9 Standard | `registry.access.redhat.com/ubi9/ubi` | General purpose, includes dnf |
| UBI9 Minimal | `registry.access.redhat.com/ubi9/ubi-minimal` | Smaller footprint, uses microdnf |
| UBI9 Micro | `registry.access.redhat.com/ubi9/ubi-micro` | Smallest, no package manager |
| UBI9 Init | `registry.access.redhat.com/ubi9/ubi-init` | systemd-enabled, multi-service |

### Language Runtime Images

| Runtime | Image |
|---------|-------|
| Node.js 20 | `registry.access.redhat.com/ubi9/nodejs-20` |
| Python 3.11 | `registry.access.redhat.com/ubi9/python-311` |
| OpenJDK 21 | `registry.access.redhat.com/ubi9/openjdk-21` |
| Go 1.21 | `registry.access.redhat.com/ubi9/go-toolset` |
| .NET 8.0 | `registry.access.redhat.com/ubi9/dotnet-80` |

### Middleware Images

| Product | Image |
|---------|-------|
| JBoss EAP 8 | `registry.redhat.io/jboss-eap-8/eap8-openjdk17-builder-openshift-rhel8` |
| Quarkus (native) | Build with `registry.access.redhat.com/ubi9/ubi-minimal` as runtime |
| AMQ Broker | `registry.redhat.io/amq7/amq-broker-rhel8` |
| AMQ Streams (Kafka) | Deployed via Strimzi/AMQ Streams Operator |
| Keycloak / SSO | `registry.redhat.io/rhbk/keycloak-rhel9` |
| 3scale APIcast | `registry.redhat.io/3scale-amp2/apicast-gateway-rhel8` |

### Selection Rules

1. Prefer `registry.access.redhat.com` (no auth required) for UBI images
2. Use `registry.redhat.io` (auth required) for product-specific images
3. Never use `docker.io` community images when a Red Hat equivalent exists
4. Always pin image tags to a specific version, not `latest`
5. For multi-stage builds, use UBI as the final runtime stage

## Certified Operators

Install operators from the Red Hat Operator catalog (`redhat-operators` CatalogSource):

| Operator | Use Case |
|----------|----------|
| OpenShift Pipelines (Tekton) | CI/CD pipelines |
| OpenShift GitOps (Argo CD) | GitOps delivery |
| OpenShift Virtualization | VM workloads on OCP |
| SR-IOV Network Operator | Hardware-accelerated networking |
| PTP Operator | IEEE 1588 time sync |
| AMQ Streams | Kafka on OCP |
| AMQ Broker | ActiveMQ Artemis on OCP |
| Red Hat SSO / Keycloak | Identity and SSO |
| 3scale | API management |
| JBoss EAP | Java EE / Jakarta EE |
| Quay | Container registry |
| ACS (StackRox) | Container security |
| ACM | Multi-cluster management |
| Compliance Operator | Compliance scanning |
| File Integrity Operator | File integrity monitoring |
| Elasticsearch / Loki | Log aggregation |
| OpenShift AI (RHOAI) | AI/ML platform, model serving, notebooks |
| NVIDIA GPU Operator | GPU acceleration for AI workloads |
| Node Feature Discovery (NFD) | Hardware feature detection for GPU nodes |

### Operator Installation Pattern

```yaml
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: <operator-name>
  namespace: <target-namespace>
spec:
  channel: stable
  name: <operator-package-name>
  source: redhat-operators
  sourceNamespace: openshift-marketplace
  installPlanApproval: Automatic
```

Always use:
- `source: redhat-operators` (not community-operators or certified-operators unless required)
- `channel: stable` (unless a specific version channel is needed)
- `installPlanApproval: Automatic` for demos (Manual for production)

## Helm Charts

Use charts from the Red Hat Helm chart repository or certified partner charts
from the OpenShift Helm chart catalog.

- Red Hat Helm repo: `https://charts.openshift.io/`
- Prefer Operators over Helm charts when both are available

## Ansible Collections

Use certified collections from Automation Hub:

| Collection | Purpose |
|------------|---------|
| `redhat.rhel_system_roles` | RHEL configuration |
| `redhat.openshift` | OpenShift management |
| `kubernetes.core` | Kubernetes resources |
| `redhat.satellite` | Satellite management |
| `ansible.netcommon` | Network abstraction |
| `cisco.ios` / `cisco.nxos` | Cisco device management |
| `junipernetworks.junos` | Juniper device management |
| `arista.eos` | Arista device management |
| `servicenow.itsm` | ServiceNow ITSM integration |
| `awx.awx` | AAP Controller management as code |

## Verification Checklist

Before finalizing any demo artifact, verify:

- [ ] All Dockerfiles use UBI9 base images
- [ ] All operators come from `redhat-operators` catalog
- [ ] All Ansible collections are certified (from Automation Hub)
- [ ] Image tags are pinned to specific versions
- [ ] No community/upstream images where certified alternatives exist
- [ ] Registry authentication is documented for `registry.redhat.io` images

For the full catalog of certified images and operators, see
[certified-catalog.md](certified-catalog.md).
