---
name: rh-openshift-expert
description: >-
  Use when the user plans or builds demos involving Red Hat OpenShift,
  containers, Kubernetes, operators, virtualization, image registries,
  multi-cluster management, or container security. The agent applies this skill
  to shape credible architectures, product touchpoints, and messaging across
  OCP core, OpenShift Virtualization, Quay, ACM, and ACS without substituting
  for official runbooks or cluster-specific validation.
---

# Red Hat OpenShift Demo Expert

Act as a **Red Hat OpenShift** subject-matter expert for demo planning and
implementation. Prefer certified Operators, OpenShift-native APIs, and patterns
aligned with product documentation. For image pulls and Operator selection,
follow **`rh-certified-components`** (`.cursor/skills/rh-certified-components/SKILL.md`).

**Deep reference:** [ocp-reference.md](ocp-reference.md) — architecture, CRDs,
OLM objects, product-specific details, and common `oc` workflows.

## Scope

### OpenShift Container Platform (core)

- **Workloads:** `Deployment` (preferred), `StatefulSet`, `DaemonSet`, Jobs/CronJobs;
  legacy `DeploymentConfig` only when discussing migration or existing estates.
- **Networking:** **Route** (OpenShift Ingress Controller), Services, NetworkPolicy;
  prefer Routes over generic `Ingress` for external HTTP(S) on OpenShift.
- **Operators:** install/managed services via OLM; cluster capabilities
  (ingress, DNS, storage) as managed Operators where applicable.
- **Service Mesh:** Red Hat OpenShift Service Mesh (Istio-based) for mTLS,
  traffic management, observability hooks in microservice demos.
- **CI/CD:** **OpenShift Pipelines** (Tekton) for builds and deploy pipelines
  on-cluster; integrate with external SCM as needed.
- **GitOps:** Red Hat OpenShift GitOps (Argo CD) for declarative cluster and
  app lifecycle demos.

### OpenShift Virtualization

KubeVirt-based VMs on OpenShift: **HyperConverged** operator, VM templates,
storage (DataVolumes/CDI), import from VMware or image, **live migration**,
and secondary networks (e.g. Multus) when the story needs multiple NICs or
L2 segments.

### Red Hat Quay

Enterprise registry: organizations/repos, **Clair** (or successor) image
scanning, **repository mirroring** for air gap or hub-and-spoke, robot accounts
and integrations with OpenShift pull secrets.

### Advanced Cluster Management for Kubernetes (ACM)

Hub-managed fleet: **ManagedCluster** enrollment, **Placement** and
**PlacementRule**-style distribution, **Policy** (GitOps-friendly governance),
**Application** / **ApplicationSet** (Argo CD on ACM), and **observability**
(thanos/grafana stack) for multi-cluster demos.

### Advanced Cluster Security for Kubernetes (ACS)

Centralized security: **Central**, **Scanner**, cluster **Sensor**, runtime
risk, **compliance** checks (e.g. CIS-oriented), Kubernetes **NetworkPolicy**
recommendations, and CI/CD gate integration for image and deployment policy.

### Monitoring and Alerting

OpenShift ships with an integrated Prometheus/Alertmanager stack. Demos often
need custom alert rules and webhook integrations:

- **PrometheusRule** -- custom alert definitions (expressions, `for` duration,
  labels, annotations) deployed as CRs in `openshift-monitoring` namespace
- **Alertmanager configuration** -- webhook receivers for forwarding alerts to
  EDA, external systems, or custom endpoints
- Common alerts for demos: `KubeNodeNotReady`, `ClusterOperatorDegraded`,
  `etcdMembersDown`, `MCPDegraded` (MachineConfigPool), `NodeFilesystemSpaceFillingUp`,
  `NodeFilesystemAlmostOutOfSpace`, `KubeNodePressure` (DiskPressure)
- Pattern: `PrometheusRule` fires -> Alertmanager routes -> webhook to EDA
  or external system
- **Alertmanager webhook routing**: configure `route` with `match` on alert names
  and `receiver` pointing to EDA webhook endpoint; use `group_wait`,
  `group_interval`, `repeat_interval` for alert batching

### NetworkPolicy for Cross-Namespace Communication

Demos involving multiple namespaces (e.g., AAP in `aap` namespace calling
LlamaStack in `rhoai-project`) require NetworkPolicy to allow traffic:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-aap-to-llamastack
  namespace: rhoai-project
spec:
  podSelector:
    matchLabels:
      app: llamastack
  ingress:
    - from:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: aap
      ports:
        - port: 8321
          protocol: TCP
```

Common cross-namespace patterns in demos:
- AAP -> LlamaStack (AI inference)
- AAP -> OpenShift Lightspeed (RAG queries)
- MCP servers -> LlamaStack (tool registration)
- Alertmanager -> EDA (webhook alerts)

## Quick Reference

| Component | Purpose | Typical demo scenarios |
|-----------|---------|-------------------------|
| **Deployment + Route** | Stateless apps, rolling updates, HTTPS edge | Cloud-native app on OpenShift, blue/green discussion |
| **Operators (OLM)** | Day-2 automation, vendor or Red Hat services | Databases, messaging, Service Mesh install |
| **OpenShift Pipelines** | Tekton CI/CD on cluster | Build from Git, scan, deploy to namespace |
| **OpenShift GitOps** | Declarative sync (Argo CD) | Git-as-source-of-truth, multi-env promotion |
| **Service Mesh** | mTLS, traffic split, observability | Canary, east-west security story |
| **OpenShift Virtualization** | VMs alongside containers | VM import, lift-and-shift + modernize |
| **Quay** | Registry, policy, scanning | Trusted supply chain, mirror to disconnected |
| **ACM** | Fleet lifecycle and policy | Day-0/1/2 at scale, policy compliance across clusters |
| **ACS** | Risk, compliance, runtime | Vuln management, admission control, SOC-style view |

## Common Demo Patterns

1. **Cloud-native app deployment** — Developer workflow: code in Git,
   OpenShift Pipelines builds image, deploys `Deployment`, exposes **Route**,
   optional GitOps for drift correction.
2. **VM-to-container migration** — Start with **OpenShift Virtualization**
   (imported VM), show live migration and storage; bridge to containerized
   microservices on the same cluster.
3. **GitOps at scale** — Single repo or app-of-apps; **Argo CD** (OpenShift
   GitOps) or ACM **ApplicationSet** to fan out to many clusters with
   **Placement**.
4. **Multi-cluster governance** — ACM hub: policies for standards (e.g. gates,
   labels, compliance), observability dashboards across **ManagedCluster**
   inventory.
5. **Supply chain security** — Build in **OpenShift Pipelines**, push to
   **Quay** with scanning, deploy with signed or policy-checked images;
   **ACS** for runtime violations and compliance reporting.
6. **Alert-driven self-healing** — Custom `PrometheusRule` fires alert
   (node failure, operator degraded, disk pressure, MCP degraded),
   Alertmanager webhook forwards to **EDA** (AAP) with throttle,
   workflow runs diagnostics (`kubernetes.core`), dual RAG (Lightspeed +
   LlamaStack KB), AI analysis, playbook generation, and automated
   remediation. Combines OCP monitoring + AAP + OpenShift AI + Lightspeed.
7. **Cross-namespace AI integration** — NetworkPolicy allowing AAP to call
   LlamaStack and Lightspeed across namespaces; ServiceAccount token auth
   for Lightspeed; ClusterIP Services for internal routing.

## Best Practices

- Install capabilities from the **certified Operator catalog**; avoid ad-hoc
  Helm on production paths unless the story explicitly covers it.
- Use **OpenShift Route** for external HTTP(S); avoid presenting raw
  `Ingress` as the primary OpenShift pattern unless integrating with specific
  controllers.
- Prefer **`Deployment`** over **`DeploymentConfig`** for new demos; mention
  `DeploymentConfig` only for brownfield or migration narratives.
- Use **OpenShift Pipelines** (Tekton) for on-cluster CI/CD demos rather than
  implying unsupported Jenkins-only paths unless documenting migration.
- Use **Red Hat Quay** or documented integrated registry patterns; align pull
  secrets and `ImageStream` usage with the chosen registry story.
- For multi-cluster, position **ACM** as the hub; avoid conflating it with
  single-cluster-only tools.
- For security demos, combine **Quay** scanning with **ACS** runtime and
  compliance for defense-in-depth messaging.
- Cite **OpenShift 4.x** (or the version the user names) and link
  **docs.redhat.com** rather than unofficial wikis.

## Documentation References

- [OpenShift Container Platform](https://docs.redhat.com/en/documentation/openshift_container_platform/)
- [OpenShift Virtualization](https://docs.redhat.com/en/documentation/openshift_container_platform/latest/html/virtualization/)
- [Red Hat Quay](https://docs.redhat.com/en/documentation/red_hat_quay/)
- [Advanced Cluster Management for Kubernetes](https://docs.redhat.com/en/documentation/red_hat_advanced_cluster_management_for_kubernetes/)
- [Advanced Cluster Security for Kubernetes](https://docs.redhat.com/en/documentation/red_hat_advanced_cluster_security_for_kubernetes/)
- [OpenShift Service Mesh](https://docs.redhat.com/en/documentation/openshift_container_platform/latest/html/service_mesh/)
- [OpenShift Pipelines](https://docs.redhat.com/en/documentation/openshift_pipelines/)
- [OpenShift GitOps](https://docs.redhat.com/en/documentation/openshift_gitops/)

## Related Skills

- **`rh-certified-components`** — UBI base images, certified Operators, image
  sources for demos consistent with Red Hat subscription and compliance
  messaging.

When details exceed this file, use [ocp-reference.md](ocp-reference.md).
