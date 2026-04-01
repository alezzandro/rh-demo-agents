# Red Hat Middleware — Detailed Reference

Supplement to **`SKILL.md`**. Use for architecture details, CR shapes, and
demo implementation notes. Validate all APIs and field names against the
product version in use.

---

## JBoss EAP

### Standalone vs domain mode

- **Standalone:** Single process configuration (`standalone.xml` or HA profile
  variants). Typical for containers and OpenShift; one pod (or replica) owns
  its config.
- **Managed domain:** Central **Domain Controller** and **Host Controllers**
  for multi-server estates. Rare in cloud-native demos; most OpenShift patterns
  treat each instance as standalone-like with externalized config.

### EAP Operator on OpenShift

- Manages **WildFly/EAP**-style applications via CRs (application image,
  replicas, env, resources). Align operator version with target EAP major.
- Prefer operator-managed routes/services over hand-rolled `Deployment` when
  the demo story is “supported path on OpenShift.”

### S2I builds

- **Source-to-Image** EAP builder images compile and layer deployments from Git
  or binary artifacts. Useful for “from repo to running pod” without a local
  Docker workflow; use **`podman`** in docs aligned with RHEL practices.

### Datasource configuration

- Configure **datasources** via subsystem settings or environment-driven
  properties in container images; on OpenShift, secrets for JDBC URL,
  username, password, and optional **Cert** mounts for TLS to DB.
- Connection pools and **XA** vs **non-XA** matter for Jakarta EE transaction
  demos.

### Clustering with JGroups

- **HA profiles** use **JGroups** for channel formation (discovery, merge,
  split-brain considerations). On Kubernetes/OpenShift, discovery often uses
  **DNS_PING** or operator-provided peer lists rather than multicast.
- Session replication demos require **HTTP** clustering and compatible
  **distributable** web apps.

---

## Camel / Fuse

### Key enterprise integration patterns (EIPs)

| Pattern | Role in demos |
|---------|----------------|
| **Content-based router** | Branch processing by message type, header, or body |
| **Splitter** | Break bulk messages into individual units for parallel handling |
| **Aggregator** | Combine correlated messages back into one outbound message |
| **Dead letter channel** | Isolate failures; retry, audit, or manual resolution path |

### Camel K on OpenShift

- **Integration** CRs define routes running as lightweight workloads on the
  cluster; fast iteration from CLI or CI.
- Integrates with **Knative** (optional) for scale-to-zero stories.

### Kamelets

- Reusable **connector** and **action** definitions (source/sink/action) that
  compose into routes; good for demo catalogs and low-code-style integration.

### YAML DSL

- Declarative route definitions in YAML for Camel K and supported runtimes;
  pairs well with GitOps and reviewable integration assets.

---

## AMQ Broker (ActiveMQ Artemis)

### Artemis configuration

- Broker behavior driven by **`broker.xml`** (acceptors, addresses, security,
  persistence). On OpenShift, often templated or mounted via **Secrets** /
  **ConfigMaps** when not fully operator-owned.

### Addresses and queues

- **Address** settings control routing semantics; **queues** bind to addresses
  for point-to-point semantics; understand **multicast** vs **anycast** for
  pub/sub vs competing consumers.

### Acceptors

- Protocol listeners (**CORE**, **AMQP**, **MQTT**, **STOMP**, **OpenWire**).
  Demo choice of protocol affects client libraries and firewall/port stories.

### Clustering

- **Artemis** clustering for HA and scale-out; bridge and **cluster
  connections** for WAN or multi-site narratives (simplified in many demos).

### AMQ Broker Operator

- Deploys and manages broker **Custom Resources** on OpenShift; prefer for
  production-like demos over raw `Deployment` unless comparing approaches.

---

## AMQ Streams (Apache Kafka on OpenShift)

### Kafka CR

- Declares **Kafka cluster**: brokers, listeners (internal/external TLS),
  storage, **ZooKeeper-less** KRaft mode when supported by version, entity
  operator for topics/users.

### KafkaTopic

- Operator-managed **topics**: partitions, replicas, retention; GitOps-friendly
  for environment promotion.

### KafkaConnect / KafkaConnector

- **KafkaConnect** cluster CR; **KafkaConnector** for individual connectors
  (source/sink). Use for JDBC, object storage, or message broker bridge demos.

### Kafka Bridge

- **HTTP** front end to Kafka for clients that cannot speak native Kafka
  protocol; useful for browser or legacy HTTP-only producers.

### MirrorMaker2

- **Active/active** or **active/passive** replication between clusters;
  geo-disaster recovery and migration demos.

### Schema Registry (where applicable)

- **Avro/JSON/Protobuf** schemas with compatibility rules; pairs with Kafka
  clients for contract evolution stories (product packaging varies by release;
  confirm against AMQ Streams release notes).

---

## 3scale API Management

### APIcast gateway

- **APIcast** (self-managed or hosted) enforces policies at the edge: auth,
  rate limits, headers, routing to **backends**.

### Backend

- Represents upstream API base URL(s); multiple **methods/metrics** map to
  products.

### System (admin)

- **Provider admin** UI/API: accounts, applications, plans, billing hooks (if
  used), analytics.

### Tenant management

- **Multi-tenant** provider model: separate providers or shared infrastructure
  depending on 3scale topology (on-prem vs SaaS).

### Developer portal

- **Developer signup**, documentation, **application credentials**; customize
  branding and content for “API product” demos.

### Rate limit policies

- **Per application**, **per plan**, or **global** limits; combine with
  **authentication** policies (API keys, OIDC) for realistic traffic control
  stories.

---

## Red Hat SSO / Keycloak

### KeycloakRealm CR (Operator)

- Declarative **realm** provisioning when using **Keycloak Operator** on
  OpenShift: realm name, themes, **SSL**, partial realm settings; complex
  clients may still use UI or **Realm JSON** import.

### Client configuration

- **Confidential** vs **public** clients, **redirect URIs**, **web origins**,
  **service accounts**, **protocol mappers** for token claims used in APIs.

### Identity providers

- **Social**, **SAML**, or **OIDC** IdP federation; attribute and **token**
  mappers for user attributes and roles.

### Role mapping

- **Realm roles**, **client roles**, **composite** roles; map IdP groups to
  roles for RBAC in apps.

### OpenShift OAuth integration

- Configure OpenShift **OAuth** to use Keycloak as **identity provider** for
  console and `oc` login demos; align **issuer** URLs, **client** secrets, and
  **CA** trust for cluster ↔ IdP TLS.

---

## Red Hat build of Quarkus

### Extensions catalog (key areas)

- **REST:** `quarkus-rest`, `quarkus-rest-client` (reactive stack naming may
  vary by version).
- **Data:** `quarkus-hibernate-orm-panache`, `quarkus-jdbc-*`, NoSQL clients.
- **Messaging:** `quarkus-smallrye-reactive-messaging-kafka`, AMQP connectors.
- **Security:** `quarkus-oidc`, `quarkus-smallrye-jwt`.
- **Observability:** `quarkus-smallrye-health`, `quarkus-micrometer-registry-prometheus`,
  OpenTelemetry extensions.
- **Kubernetes/OpenShift:** `quarkus-kubernetes`, `quarkus-openshift` for
  manifest generation and deployment metadata.

### Dev services

- Testcontainers-backed **automatic** brokers, databases, Kafka for `quarkus
  dev`; reduces demo laptop setup when allowed by policy.

### Native build

- **GraalVM / Mandrel** native image: faster startup, lower RSS; longer builds
  and reflection configuration for some libraries—call out trade-offs in demos.

### Dockerfile.native vs Dockerfile.jvm

- **JVM** image: broader compatibility, traditional tuning, faster CI builds.
- **Native** image: minimal footprint runtime; use **UBI**-based runtime
  images per Red Hat documentation for supported combinations.

### Quarkus Operator

- Optional OpenShift path for **QuarkusApplication**-style lifecycle where
  offered; confirm CRD availability on target cluster version.

---

## Spring Boot on Red Hat

### Supported starters

- Use **Red Hat Spring Boot** BOM and **Red Hat Spring Boot starters** for
  supported stack alignment (messaging, data, cloud) per
  [Red Hat support for Spring Boot](https://access.redhat.com/documentation/en-us/red_hat_support_for_spring_boot)
  for the chosen Spring Boot major.

### Deploying with JKube

- **Eclipse JKube** Kubernetes/OpenShift goals generate resources and deploy
  from Maven/Gradle; aligns with “build in CI, deploy to OCP” demos without
  hand-written YAML for simple cases.

### Spring Cloud Kubernetes

- **ConfigMaps** and **Secrets** as property sources, **discovery** via
  Kubernetes services, **reload** patterns; fits Spring apps running on
  OpenShift with platform-native config.

---

## Cross-links

- OpenShift routes, Operators, and probes: **`rh-openshift-expert`** skill.
- Certified images and UBI policy: **`rh-demo-conventions`** / certified
  components skill if present in the repo.
