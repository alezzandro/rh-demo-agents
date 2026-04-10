---
name: rh-openshift-ai-expert
description: >-
  Use when planning or building demos involving AI/ML workloads, model serving,
  data science pipelines, Jupyter notebooks, LLM inference, model monitoring,
  distributed training, or Red Hat OpenShift AI on OpenShift.
---

# Red Hat OpenShift AI Expert

Domain expertise for Red Hat OpenShift AI (RHOAI) 3 -- the AI/ML platform built
on OpenShift for developing, training, serving, and monitoring machine learning
models at scale.

## Overview

OpenShift AI provides a full MLOps lifecycle on OpenShift:

1. **Develop** -- Jupyter notebooks with pre-built data science images
2. **Train** -- Distributed training with Ray and PyTorch on GPU/accelerator nodes
3. **Serve** -- Model serving with KServe (single-model) or ModelMesh (multi-model)
4. **Monitor** -- TrustyAI for bias detection, drift monitoring, explainability
5. **Orchestrate** -- Data Science Pipelines (based on Kubeflow Pipelines v2)

RHOAI runs as an operator on OpenShift and integrates tightly with the OCP
ecosystem (Routes, storage, GPU Operators, service mesh).

## Key Components

| Component | Purpose | CRD / Resource |
|-----------|---------|----------------|
| RHOAI Operator | Installs and manages the platform | `DataScienceCluster`, `DSCInitialization` |
| Dashboard | Web UI for data science projects | Part of RHOAI operator |
| Notebooks | Jupyter-based development environment | `Notebook` (Kubeflow) |
| Data Science Pipelines | ML workflow orchestration | `DataSciencePipelinesApplication` |
| Model Serving (KServe) | Single-model serving with autoscaling | `InferenceService`, `ServingRuntime` |
| Model Serving (ModelMesh) | Multi-model serving, shared GPU | `InferenceService`, `ServingRuntime` |
| Model Registry | Central catalog of trained models | `ModelRegistry` |
| TrustyAI | Fairness, explainability, drift detection | `TrustyAIService` |
| Distributed Workloads | Ray, PyTorch distributed training | `RayCluster`, `RayJob`, `AppWrapper` |
| LlamaStack | Agentic AI orchestration layer over vLLM | `LlamaStackDistribution` |
| OpenShift Lightspeed | RAG over OCP product documentation | `OLSConfig` |
| Gen AI Playground | Interactive chat with models + MCP tools | `OdhDashboardConfig` (genAiStudio) |
| Hardware Profiles | GPU/accelerator resource templates | `HardwareProfile` (dashboard) |

## Quick Reference

| Feature | Technology | Demo Scenario |
|---------|------------|---------------|
| LLM serving | vLLM on KServe + NVIDIA GPU | "Deploy and query an LLM on OpenShift" |
| Agentic AI | LlamaStack + vLLM + MCP servers | "AI agent with tool use on OpenShift" |
| RAG (product docs) | OpenShift Lightspeed (FAISS + OCP docs) | "AI assistant with product knowledge" |
| RAG (operational KB) | LlamaStack vector store (runbooks) | "AI with operational memory" |
| Dual RAG | Lightspeed + LlamaStack KB together | "Self-healing with product docs + ops KB" |
| AI-in-the-loop ops | EDA + AAP + LlamaStack (chat completions) | "Self-healing cluster with AI diagnostics" |
| Gen AI Playground | RHOAI 3.3 chat UI + MCP tools | "Interactive AI assistant in OCP console" |
| Notebook development | JupyterLab with PyTorch/TensorFlow images | "Data scientist self-service workspace" |
| ML pipeline | DSP with Kubeflow Pipelines SDK | "Automated model training pipeline" |
| Model monitoring | TrustyAI + Prometheus + Grafana | "Detect model bias and data drift" |
| Distributed training | Ray on OCP with multi-GPU | "Fine-tune an LLM across GPU nodes" |
| Edge inference | KServe + ACM for edge deployment | "Deploy inference at the telco edge" |
| Multi-model serving | ModelMesh with shared GPUs | "Cost-efficient multi-tenant model serving" |

## Common Demo Patterns

### 1. LLM Serving on OpenShift

Deploy a large language model using vLLM runtime on KServe with GPU acceleration.

- Products: OpenShift AI, OpenShift (GPU Operator, Node Feature Discovery)
- Key resources: `ServingRuntime` (vLLM), `InferenceService`, NVIDIA GPU nodes
- Storage: S3-compatible (ODF/NooBaa, MinIO) for model weights
- Networking: OpenShift Route or Service Mesh for inference endpoint

### 2. Retrieval-Augmented Generation (RAG)

Build a RAG chatbot that combines an LLM with enterprise documents.

- Products: OpenShift AI (serving), Middleware (vector DB, application)
- Components: vLLM serving, embedding model, PGVector/Milvus, LangChain app
- Pipeline: Ingest docs -> embed -> store vectors -> query with LLM

### 3. MLOps Pipeline

End-to-end pipeline: data prep, training, evaluation, model registry, serving.

- Products: OpenShift AI (DSP, notebooks, model registry, serving)
- Key resources: `DataSciencePipelinesApplication`, `InferenceService`
- Integration: Tekton for CI/CD triggers, Git for pipeline versioning

### 4. Distributed Fine-Tuning

Fine-tune a foundation model using distributed training across GPU nodes.

- Products: OpenShift AI (distributed workloads), OpenShift (GPU Operator)
- Key resources: `RayCluster`, `RayJob`, `AppWrapper` (Kueue integration)
- Requires: Multi-GPU nodes, NCCL, high-bandwidth networking

### 5. AI at the Telco Edge

Deploy inference models at edge locations for low-latency telco use cases.

- Products: OpenShift AI, ACM (fleet management), OpenShift (SNO at edge)
- Pattern: Train centrally, deploy at edge via GitOps/ACM policies
- Use cases: Network anomaly detection, RAN optimization, predictive maintenance

### 6. Self-Healing Cluster with AI (Dual RAG)

Closed-loop automation: alert -> diagnostics -> dual RAG -> AI analysis -> remediation.

- Products: OpenShift (monitoring, Lightspeed), AAP (EDA + workflows),
  OpenShift AI (LlamaStack + vLLM)
- RAG sources: (1) OpenShift Lightspeed for product documentation, (2) LlamaStack
  vector store for operational runbooks and past resolutions
- Flow: Prometheus alert -> Alertmanager webhook -> EDA -> AAP workflow ->
  gather diagnostics (`kubernetes.core`) -> query Lightspeed (`/v1/query`) ->
  search operational KB (`/v1/vector_stores/{id}/search`) -> call LlamaStack
  `/v1/chat/completions` with combined context -> parse RCA + playbook ->
  push to Git -> create AAP Job Template -> update ServiceNow
- Architecture: **AI proposes, Ansible executes** -- all integrations via
  `ansible.builtin.uri`; MCP servers deployed separately for Gen AI Playground
- Knowledge base branching: check if remediation JT already exists in AAP;
  if yes, route to auto-remediation (known-incident path via workflow
  failure_nodes); if no, invoke AI for new analysis

### 7. Agentic AI with LlamaStack + MCP (Interactive)

Deploy an AI agent that uses tools (MCP servers) to interact with external
systems interactively -- for demos where the model drives tool calls.

- Products: OpenShift AI (vLLM + LlamaStack), Gen AI Playground
- Key resources: `LlamaStackDistribution`, `InferenceService`, MCP Deployments
- LlamaStack provides: Responses API (agentic), vector store (RAG/memory),
  tool registration (MCP servers), embeddings
- Best with larger models (70B+); smaller models (24B) may struggle with
  reliable multi-tool orchestration
- Pattern: Gen AI Playground or Responses API with tool definitions;
  LlamaStack routes inference to vLLM and tool calls to MCP servers

## GPU and Accelerator Support

RHOAI requires accelerator hardware for model training and serving:

| Accelerator | Operator | Notes |
|-------------|----------|-------|
| NVIDIA GPU | NVIDIA GPU Operator + Node Feature Discovery (NFD) | Most common, supports A100/H100/L40S |
| Intel Gaudi | Intel Gaudi Operator | HPU accelerators for training |
| AMD Instinct | AMD GPU Operator | ROCm-based GPU support |

GPU Operator deployment:
1. Install Node Feature Discovery Operator
2. Install NVIDIA GPU Operator from `certified-operators` catalog
3. GPUs are auto-detected and exposed as `nvidia.com/gpu` resources

## Notebook Images

Pre-built notebook images shipped with RHOAI:

| Image | Includes |
|-------|----------|
| Standard Data Science | NumPy, Pandas, Scikit-learn, Matplotlib |
| PyTorch | PyTorch + CUDA, Jupyter, standard DS libs |
| TensorFlow | TensorFlow + CUDA, Jupyter, standard DS libs |
| Minimal | Minimal Jupyter environment |
| CUDA | Base CUDA toolkit for custom GPU workloads |
| HabanaAI | Intel Gaudi / Habana AI libraries |

Custom notebook images can be added via `ImageStream` in the RHOAI dashboard.

## Model Serving Runtimes

| Runtime | Use Case | Protocol |
|---------|----------|----------|
| vLLM | LLM inference (recommended for GenAI) | OpenAI-compatible API |
| Text Generation Inference (TGI) | LLM inference (HuggingFace) | REST / gRPC |
| Caikit + TGIS | NLP models with Caikit framework | REST / gRPC |
| OpenVINO Model Server | Optimized inference on Intel CPUs | REST / gRPC |
| Triton Inference Server | Multi-framework (ONNX, TensorRT, PyTorch) | REST / gRPC |

### ServingRuntime Example (vLLM)

```yaml
apiVersion: serving.kserve.io/v1alpha1
kind: ServingRuntime
metadata:
  name: vllm-runtime
spec:
  supportedModelFormats:
    - name: vLLM
      autoSelect: true
  containers:
    - name: kserve-container
      image: quay.io/modh/vllm:stable
      ports:
        - containerPort: 8000
          protocol: TCP
      env:
        - name: MODEL_ID
          value: /mnt/models
```

### InferenceService Example

```yaml
apiVersion: serving.kserve.io/v1beta1
kind: InferenceService
metadata:
  name: my-llm
  annotations:
    serving.kserve.io/deploymentMode: RawDeployment
spec:
  predictor:
    model:
      modelFormat:
        name: vLLM
      runtime: vllm-runtime
      storageUri: s3://models/my-llm
      resources:
        requests:
          nvidia.com/gpu: "1"
        limits:
          nvidia.com/gpu: "1"
```

## OpenShift Lightspeed (Product Documentation RAG)

OpenShift Lightspeed is the AI assistant built into the OCP console. It ships
with a FAISS vector index over the full OCP documentation corpus (18,000+
embedded chunks). For demos, it serves as a **product documentation RAG layer**:

- **`/v1/query` API** -- send an alert description, get remediation guidance
  with referenced documentation (titles + URLs)
- **SA token auth** -- create a ServiceAccount with `ols-user` ClusterRoleBinding,
  mount its token secret, use as Bearer token
- **Returns**: response text + `referenced_documents` array (doc_title, doc_url)
- **Separation of concerns**: Lightspeed provides product knowledge;
  `gather-cluster-diagnostics.yml` provides live cluster state deterministically

### When to Use Lightspeed vs LlamaStack Vector Store

| Source | Content | Use Case |
|--------|---------|----------|
| OpenShift Lightspeed | OCP product docs (18,000+ chunks) | "What does the documentation say about this alert?" |
| LlamaStack vector store | Operational runbooks, past resolutions | "Have we seen this before? What worked?" |
| Both (dual RAG) | Combined context in one prompt | Self-healing: product knowledge + operational memory |

## LlamaStack (AI Orchestration Layer)

LlamaStack provides an orchestration layer on top of vLLM for building AI agents:

- **Chat Completions API** (`/v1/chat/completions`) -- standard OpenAI-compatible
  endpoint; preferred for production workflows called from Ansible playbooks
- **Responses API** (`/v1/responses`) -- agentic endpoint with tool definitions;
  use for interactive/demo scenarios where the model drives tool calls
- **Vector Store Search** (`/v1/vector_stores/{id}/search`) -- search documents
  in a named vector store; returns scored results with filenames and content
- **Vector I/O** -- built-in vector store (PostgreSQL + pgvector or FAISS) for
  RAG and memory; insert/query embeddings without external vector DB
- **MCP Tool registration** -- register MCP servers for the Responses API and
  Gen AI Playground; not used in production Ansible workflows
- **Embeddings** -- sentence-transformers for embedding generation (local, no GPU needed)

### AI Proposes, Ansible Executes

For production-grade demos, prefer this architectural pattern:

- **AI handles analysis** -- the model receives diagnostics + RAG context and
  produces a Root Cause Analysis + remediation playbook via `/v1/chat/completions`
- **Ansible handles orchestration** -- AAP workflow playbooks drive every
  integration (ServiceNow, Gitea, AAP Controller) using `ansible.builtin.uri`
  REST API calls; each step is deterministic, observable, and auditable

This hybrid approach shows that AI augments the automation platform rather
than replacing it. The AI proposes; Ansible executes. MCP servers remain
deployed for interactive Gen AI Playground demos but the production workflow
uses deterministic Ansible playbooks.

### Structured AI Output Parsing

When calling `/v1/chat/completions` from Ansible, use marker-based output:

```
SECTION 1: Root Cause Analysis (plain text)
---PLAYBOOK--- (YAML remediation playbook)
---EXTRA_VARS--- (JSON with incident-specific variables)
```

Parse in Ansible with `split('---PLAYBOOK---')` and handle missing markers
gracefully with fallback logic.

### LlamaStackDistribution CR

```yaml
apiVersion: llamastack.io/v1alpha1
kind: LlamaStackDistribution
metadata:
  name: my-agent
  namespace: rhoai-project
spec:
  replicas: 1
  server:
    distribution:
      name: rh-dev
    containerSpec:
      port: 8321
      env:
        - name: VLLM_URL
          value: "http://my-model-predictor.rhoai-project.svc:8000/v1"
        - name: INFERENCE_MODEL
          value: "granite-3-1-8b-starter"
        - name: POSTGRES_HOST
          value: "llamastack-postgres.rhoai-project.svc.cluster.local"
        - name: ENABLE_SENTENCE_TRANSFORMERS
          value: "true"
```

### MCP Servers on OpenShift

MCP (Model Context Protocol) servers expose tools that LlamaStack can call.
Deploy as standard OCP Deployments + Services:

- Build from UBI9 Python images (`registry.access.redhat.com/ubi9/python-311`)
- Expose on port 8080 via ClusterIP Service
- LlamaStack discovers MCP servers by label and invokes tools via HTTP

Common MCP servers for demos:
- **AAP MCP** -- create/run job templates, sync projects
- **ServiceNow MCP** -- create/update incidents, add work notes
- **Git MCP** -- push files to repositories

### System Prompts as Jinja2 Templates

For Ansible-integrated AI demos, system prompts are Jinja2 templates that
include dynamic context (alert details, diagnostics, incident numbers):

```
You are an expert OpenShift engineer.
Alert: {{ alert_name }}
Diagnostics: {{ diagnostics | to_nice_json }}
Incident: {{ snow_incident_number }}
Execute all steps using the available tools.
```

## Gen AI Playground (RHOAI 3.3)

Interactive chat UI in the OpenShift AI dashboard for testing models with
MCP tool calling. Enable with:

1. `genAiStudio: true` in `OdhDashboardConfig`
2. `opendatahub.io/genai-asset: "true"` label on the InferenceService
3. `gen-ai-aa-mcp-servers` ConfigMap listing MCP server endpoints

Useful for demonstrating that the same model powering the automated workflow
is also accessible as an interactive assistant with tool-calling capabilities.

## Best Practices

- Use KServe single-model serving for LLMs (not ModelMesh)
- Use ModelMesh for many small models sharing GPU resources
- Store models in S3-compatible storage (ODF NooBaa or MinIO), not PVCs for large models
- Use `ServingRuntime` CRs to define reusable serving configurations
- Enable autoscaling on `InferenceService` for variable load demos
- Use TrustyAI from Day 1 -- monitoring should be part of the demo, not an afterthought
- Pin notebook image tags; do not use `latest` in demos
- Prefer "AI proposes, Ansible executes" for production-grade demos; use MCP
  tool calling only for interactive/playground demos or with large models (70B+)
- For RAG, combine Lightspeed (product docs) with LlamaStack vector store
  (operational KB) as dual sources in the same prompt
- Build MCP servers on UBI9 Python images; deploy as standard OCP workloads
- Use NetworkPolicy to allow cross-namespace traffic (e.g., AAP -> LlamaStack)
- Reference `rh-certified-components` for all base images and operators

## Integration with Other Domains

| Domain | Integration Point |
|--------|-------------------|
| OpenShift | GPU Operator, Routes, ODF storage, Service Mesh, Lightspeed, NetworkPolicy |
| Ansible | `ansible.builtin.uri` to LlamaStack/Lightspeed APIs, EDA triggers, AAP workflows |
| Middleware | Application layer for RAG (Quarkus/Camel), AMQ Streams for event-driven inference |
| Telco | Edge inference with ACM, network anomaly detection models |
| RHEL | Custom notebook images built on UBI9, GPU driver host config |

## Documentation References

- [OpenShift AI 3 Documentation](https://docs.redhat.com/en/documentation/red_hat_openshift_ai_self-managed/3/)
- [OpenShift AI on cloud services](https://docs.redhat.com/en/documentation/red_hat_openshift_ai_cloud_service/)
- [Gen AI Playground (RHOAI 3.3)](https://docs.redhat.com/en/documentation/red_hat_openshift_ai_self-managed/3.3/html-single/experimenting_with_models_in_the_gen_ai_playground/)
- [OpenShift Lightspeed](https://docs.redhat.com/en/documentation/red_hat_openshift_lightspeed/)
- [KServe Documentation](https://kserve.github.io/website/)
- [Kubeflow Pipelines SDK](https://www.kubeflow.org/docs/components/pipelines/)
- [NVIDIA GPU Operator on OCP](https://docs.nvidia.com/datacenter/cloud-native/openshift/latest/index.html)
- [vLLM Documentation](https://docs.vllm.ai/)

For detailed API reference and configuration examples, see
[openshift-ai-reference.md](openshift-ai-reference.md).
