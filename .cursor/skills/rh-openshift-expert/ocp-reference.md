# OpenShift and Related Products — Detailed Reference

Companion to [SKILL.md](SKILL.md). Version numbers in demos should match what
the user’s environment runs (e.g. OpenShift 4.16, 4.17); this document is
product-oriented, not a substitute for release notes.

---

## OpenShift 4.x architecture

### Control plane

- Runs on control plane nodes (typically three for HA): **etcd** (cluster state),
  **API server**, **scheduler**, **controller managers** (including machine and
  cluster operators).
- **Cluster Operators** reconcile platform components (network, ingress, DNS,
  image registry, etc.); status via `ClusterOperator` resources.

### Worker nodes

- Run user workloads: kubelet, CRI-O (default container runtime), SDN/OVN-K
  node components.
- **Machine API** / **MachineSet** (optional, cloud/bare-metal integrations)
  scales workers; bare metal may use **BareMetalHost** (Metal3) patterns.

### Infrastructure nodes

- Nodes labeled/tainted for infrastructure workloads (ingress, registry,
  monitoring, logging) to separate them from general app **worker** capacity.
- Sizing and labeling follow subscription and support guidelines in
  [OpenShift documentation](https://docs.redhat.com/en/documentation/openshift_container_platform/).

---

## Key APIs and resources

### Route

- OpenShift **`Route`** exposes Services via the **Ingress Controller**
  (HAProxy-based default). Fields include `host`, `tls`, `to` (Service target),
  `wildcardPolicy`.
- Preferred for external HTTP(S) demos on OpenShift versus generic **`Ingress`**
  unless a specific Ingress Controller story is required.

### DeploymentConfig vs Deployment

- **`Deployment`** — Kubernetes standard; rolling/recreate strategies; use for
  new demos.
- **`DeploymentConfig`** — OpenShift legacy; triggers (config, image, Git);
  retain for brownfield/migration narratives only.

### BuildConfig and ImageStream

- **`BuildConfig`** — Source-to-Image (S2I), Docker, or custom builds; outputs
  often push to internal registry and update **`ImageStream`** tags.
- **`ImageStream`** — Abstraction for images; enables triggers and import from
  external registries (e.g. Quay) via `ImageStreamImport` or sync mechanisms.

### Other frequent objects

- **`Project`** / **`Namespace`** — Quota, RBAC, network isolation boundaries.
- **`NetworkPolicy`** — Default allow-all inter-namespace unless restricted;
  align with CNI (OVN-Kubernetes) capabilities.
- **`PersistentVolumeClaim`** — Storage classes (CSI Operators) for stateful
  demos.

---

## OpenShift Virtualization (KubeVirt)

### HyperConverged CR

- **`HyperConverged`** (namespace `openshift-cnv` typically) — top-level
  configuration for OpenShift Virtualization operator; enables features,
  workload defaults, and operator-wide settings.
- Install via **OpenShift Virtualization** Operator from OperatorHub; verify
  `kubevirt-hyperconverged` CSV phase.

### VM templates

- **`Template`** (OpenShift templates) or **Instance types / preferences** (newer
  UX) for standardized VM provisioning.
- **`VirtualMachine`** — desired VM spec (CPU, memory, disks, networks);
  **`VirtualMachineInstance`** — running pod-like instance.

### DataVolumes and import

- **CDI** **`DataVolume`** / **`PersistentVolumeClaim`** with data source
  annotations — populate disks from HTTP, registry, S3, or **VMware** import
  (virt-v2v / migration tooling depending on version).
- **Live migration** — shared storage and compatible CPU policies; demos often
  show draining a node while VM stays up.

### Networking (Multus)

- **Multus** CNI: **`NetworkAttachmentDefinition`** references additional
  networks (bridge, macvlan, SR-IOV where supported).
- VM interfaces attach to default cluster network and/or secondary NADs for
  L2-style or multi-homed scenarios.

---

## Red Hat Quay

### QuayRegistry CR

- **Red Hat Quay** on OpenShift: **`QuayRegistry`** drives deployment topology,
  components (mirror, clair/scanner), TLS, and storage backends.
- Superuser and config often via Quay **config bundle** or operator-managed
  secrets.

### Clair / image scanning

- Vulnerability scanning integrated with Quay; policy engines can block pulls or
  warn on severity thresholds (exact feature names vary by Quay major version).

### Repository mirroring

- **Repository mirror** / **mirror robot** patterns for pulling from upstream
  through Quay to air-gapped or regulated clusters; align with OpenShift
  **ImageContentSourcePolicy** / **ImageDigestMirrorSet** (4.x naming) for
  disconnected installs.

### Robot accounts and OpenShift

- **Robot accounts** — long-lived credentials for CI or cluster pull secrets;
  map to **`dockercfg`** secrets in namespaces and **global pull secret** only
  when documenting supported cluster-wide patterns.

---

## Advanced Cluster Management for Kubernetes (ACM)

### ManagedCluster

- **`ManagedCluster`** — registered spoke cluster on the hub; labels for
  placement and policy binding.
- **Klusterlet** agent on spoke talks to hub APIs; demos cover import token or
  automatic discovery flows per doc for the ACM release.

### Placement

- **`Placement`** (and related **PlacementDecision**) — selects clusters by
  label/claim predicates for policy or application distribution.

### Policy

- **Governance** policies (configuration, certificates, compliance) applied via
  hub templates; often Git-backed for GitOps-style governance demos.

### Application and ApplicationSet

- **`Application`** resources integrate with Argo CD on the hub;
  **`ApplicationSet`** generators (cluster list, Git matrix) fan out apps to
  many clusters.

### Observability

- ACM observability stack (e.g. Thanos, Grafana) for multi-cluster metrics;
  link to user workload monitoring vs platform monitoring distinctions in docs.

---

## Advanced Cluster Security for Kubernetes (ACS)

### Central, Scanner, Sensor

- **Central** — UI, policy, vulnerability DB aggregation, API.
- **Scanner** — image analysis (components, CVEs).
- **Sensor** — per-cluster agent: runtime detection, deployment listening,
  network flow visibility where enabled.

### Compliance

- **Compliance** checks (profiles such as CIS Kubernetes, OpenShift-focused
  controls where offered) — schedule scans, export evidence for audit-style
  demos.

### Network policies

- Suggested **NetworkPolicy** YAML from ACS; contrasts with default-open
  cluster behavior; pair with **ACS** runtime alerts for lateral movement.

### CI/CD integration

- **roxctl** / API gates in pipelines to fail on critical CVEs or policy;
  integrate with **OpenShift Pipelines** and **Quay** scan results for a unified
  supply-chain story.

---

## Operator Lifecycle Manager (OLM)

### OperatorGroup

- **`OperatorGroup`** — scopes Operators to namespaces (single vs multi);
  defines **targetNamespaces** for copied CSVs and dependency resolution.

### Subscription

- **`Subscription`** — channel, approval (Automatic/Manual), starting CSV;
  ties catalog entry to installed Operator.

### CatalogSource

- **`CatalogSource`** — gRPC or **File-based catalog** (`Image` or `ConfigMap`)
  exposing Operator bundles; **redhat-operators** default on OpenShift.

### Common demo flow

1. Create **CatalogSource** (if custom or mirrored catalog).
2. Create **OperatorGroup** in target namespace (or use global operators).
3. Create **Subscription**; approve **InstallPlan** if Manual.
4. Verify **ClusterServiceVersion** (`CSV`) phase **Succeeded** and CRDs
   installed.

---

## Common `oc` commands for demo workflows

Replace resource names and namespaces with demo values.

```bash
# Context and cluster info
oc whoami
oc cluster-info
oc get nodes -o wide
oc get clusterversion
oc get co

# Projects and quotas
oc new-project demo-app
oc describe quota -n demo-app

# Applications
oc get deploy,sts,ds -n demo-app
oc get route -n demo-app
oc expose svc myservice -n demo-app

# Builds (if using BuildConfig)
oc start-build myapp -n demo-app --follow
oc get bc,is -n demo-app

# Operators
oc get og,sub,csv -n openshift-operators
oc get installplan -n my-operator-ns
oc get catsrc -A

# Storage
oc get pvc,sc -n demo-app

# Virtualization (when installed)
oc get vm,vmi -n openshift-cnv
oc get hyperconverged -n openshift-cnv

# Debugging
oc logs deploy/myservice -n demo-app
oc describe pod -l app=myservice -n demo-app
oc debug node/<node-name>
```

### Tips

- Use **`oc explain <resource>.<field>`** for field-level help during live demos.
- Prefer **`--as`** / impersonation only in lab contexts with clear RBAC stories.
- For multi-cluster ACM demos, hub context uses **`oc`** against hub API;
  spokes may use **`oc`** with distinct kubeconfigs or **cluster proxy** flows
  per ACM documentation.

---

## Further reading

Official entry points (version-specific paths under each product):

- [OpenShift Container Platform](https://docs.redhat.com/en/documentation/openshift_container_platform/)
- [Red Hat Quay](https://docs.redhat.com/en/documentation/red_hat_quay/)
- [Red Hat Advanced Cluster Management for Kubernetes](https://docs.redhat.com/en/documentation/red_hat_advanced_cluster_management_for_kubernetes/)
- [Red Hat Advanced Cluster Security for Kubernetes](https://docs.redhat.com/en/documentation/red_hat_advanced_cluster_security_for_kubernetes/)
