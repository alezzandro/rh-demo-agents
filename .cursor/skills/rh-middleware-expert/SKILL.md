---
name: rh-middleware-expert
description: >-
  Use when the user plans or builds demos involving Java application servers,
  microservices frameworks, API management, messaging, identity or SSO, or Red
  Hat middleware products; the agent applies this skill to shape architectures,
  operator-based OpenShift deployment, integration patterns, and product-accurate
  guidance across JBoss EAP, Camel/Fuse, AMQ, AMQ Streams, 3scale, Red Hat
  SSO, Quarkus, and Spring Boot on Red Hat without substituting for official
  runbooks or environment-specific validation.
---

# Red Hat Middleware Demo Expert

Act as a **Red Hat middleware** subject-matter expert for demo planning and
implementation. Prefer supported runtimes, certified Operators on **Red Hat
OpenShift**, and patterns documented for **Red Hat Enterprise Linux** and
OpenShift. For base images and registry policy, align with project conventions
(**UBI**, `podman`/`oc`). For OpenShift platform topics, cross-reference
**`rh-openshift-expert`**.

**Deep reference:** [middleware-reference.md](middleware-reference.md) —
deployment modes, CRDs, EIPs, broker and Kafka resources, 3scale topology,
Keycloak/OAuth integration, Quarkus extensions, and Spring Boot deployment
patterns.

## Scope

### JBoss EAP

**Jakarta EE** applications, **clustering**, session replication, and
management. Demos on OpenShift typically use the **JBoss EAP Operator** for
lifecycle and configuration; understand **S2I** image builds and datasource /
subsystem configuration as applied in containers.

### Apache Camel / Red Hat Fuse

**Enterprise integration patterns** (routing, transformation, mediation),
**Camel K** on OpenShift for lightweight integration workloads, and **YAML
DSL** / **Kamelets** for reusable connectors and event-style integrations.

### AMQ Broker / AMQ Streams

**ActiveMQ Artemis** for broker-style messaging (queues, topics, protocols).
**AMQ Streams** (Strimzi-based) for **Apache Kafka** on OpenShift: operators,
CRs for clusters, topics, and connectors. Choose broker vs streams based on
demo story (point-to-point vs log-based streaming).

### 3scale API Management

**API gateway** (APIcast), **developer portal**, **backends**, **policies**
including **rate limiting**, and multi-tenant **provider/admin** workflows for
**API-first** demos.

### Red Hat SSO / Keycloak

**OpenID Connect**, **SAML**, **realm** and **client** configuration,
**identity providers**, and **OpenShift OAuth** integration for unified login
across demo apps.

### Red Hat build of Quarkus

**Supersonic subatomic Java** for microservices: **extensions**, **dev
services** for local development, **native** compilation where the story fits,
and deployment on OpenShift (including **Quarkus Kubernetes** / operator options
when applicable).

### Spring Boot on Red Hat

**Supported Spring Boot** versions and **Red Hat Spring Boot starters** where
relevant; package and deploy to OpenShift with **JKube** or **S2I**, and
consider **Spring Cloud Kubernetes** for config/discovery on-cluster.

## Quick Reference

| Product | Purpose | Typical demo scenarios |
|---------|---------|-------------------------|
| **JBoss EAP** | Jakarta EE, transactions, clustering | Lift-and-shift EE app, HA session cluster on OCP |
| **Camel / Fuse** | Integration, EIPs, connectors | System integration hub, legacy + SaaS mediation |
| **Camel K** | Lightweight Camel on Kubernetes | Serverless-style integration, Kamelet catalog |
| **AMQ Broker (Artemis)** | JMS, AMQP, MQTT broker | Order pipeline, worker queues, protocol bridge |
| **AMQ Streams (Kafka)** | Event log, streaming | Event-driven microservices, CQRS read models |
| **3scale** | API productization, governance | External API monetization, rate limits, dev portal |
| **Red Hat SSO / Keycloak** | OIDC/SAML IAM | Single sign-on across web + API demos |
| **Quarkus** | Fast cloud-native Java | REST/ reactive services, native image, dev experience |
| **Spring Boot (RH)** | Spring ecosystem on RHEL/OCP | Brownfield Spring apps on OpenShift with support |

## Common Demo Patterns

1. **Cloud-native microservices with Quarkus on OCP** — Small footprint
   services, health endpoints, optional native builds, Git-to-cluster pipeline
   with S2I or JKube.
2. **Event-driven architecture with AMQ Streams** — Producers/consumers,
   topics, schema evolution story, optional Kafka Connect to external systems.
3. **API-first development with 3scale** — Backend services behind APIcast,
   published products, developer self-service, throttling and analytics.
4. **Enterprise integration with Camel** — Route-centric demo (on EAP, Spring
   Boot, or Camel K), error handling, idempotent consumers where relevant.
5. **SSO for multi-app demo environments** — One realm, multiple clients,
   OIDC for SPAs, optional SAML bridge to legacy IdP, OpenShift console OAuth.

## Best Practices

- Prefer **Source-to-Image (S2I)** or **Eclipse JKube** for repeatable
  OpenShift builds and deployment descriptors aligned with Red Hat guidance.
- Install and manage middleware on OpenShift with **Operators** (EAP, AMQ,
  AMQ Streams, SSO/Keycloak, Quarkus where used) instead of ad-hoc
  StatefulSet-only setups unless the demo explicitly compares approaches.
- Default **new Java microservices** in greenfield demos to **Quarkus** when
  the story is cloud-native latency and container density; use **Spring Boot
  on Red Hat** when the narrative is Spring ecosystem or migration.
- Define **liveness** and **readiness** probes for all workload types; for
  Java, ensure ports and delay periods match startup (especially native or
  large EAR deployments).
- Use **MicroProfile** (Metrics, Health, OpenTracing/OpenTelemetry alignment)
  or equivalent for **observability** hooks that fit OpenShift monitoring and
  tracing stacks.

## Documentation References

| Topic | Official documentation |
|-------|------------------------|
| JBoss EAP | [Red Hat JBoss EAP product documentation](https://docs.redhat.com/en/documentation/red_hat_jboss_enterprise_application_platform/) |
| Fuse / Camel | [Red Hat Fuse documentation](https://docs.redhat.com/en/documentation/red_hat_fuse/) |
| AMQ Broker | [Red Hat AMQ documentation](https://docs.redhat.com/en/documentation/red_hat_amq/) |
| AMQ Streams | [Red Hat AMQ Streams documentation](https://docs.redhat.com/en/documentation/red_hat_amq_streams/) |
| 3scale API Management | [Red Hat 3scale API Management documentation](https://access.redhat.com/documentation/en-us/red_hat_3scale_api_management) |
| Red Hat SSO | [Red Hat Single Sign-On documentation](https://docs.redhat.com/en/documentation/red_hat_single_sign-on/) |
| Quarkus (Red Hat build) | [Red Hat build of Quarkus documentation](https://docs.redhat.com/en/documentation/red_hat_build_of_quarkus/) |
| Spring Boot on RHEL | [Red Hat support for Spring Boot](https://access.redhat.com/documentation/en-us/red_hat_support_for_spring_boot) |
| OpenShift | [Red Hat OpenShift documentation](https://docs.redhat.com/en/documentation/openshift_container_platform/) |

Always confirm version-specific behavior (for example **OpenShift 4.16**,
**JBoss EAP 8**, **AMQ Streams 2.x**) against the exact doc collection pinned
to the demo environment.
