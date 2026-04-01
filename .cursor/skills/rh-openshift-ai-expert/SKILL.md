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
| Hardware Profiles | GPU/accelerator resource templates | `HardwareProfile` (dashboard) |

## Quick Reference

| Feature | Technology | Demo Scenario |
|---------|------------|---------------|
| LLM serving | vLLM on KServe + NVIDIA GPU | "Deploy and query an LLM on OpenShift" |
| Agentic AI | LlamaStack + vLLM + MCP servers | "AI agent with tool use on OpenShift" |
| RAG pipeline | LlamaStack vector store or PGVector | "Enterprise RAG chatbot on OCP" |
| AI-in-the-loop ops | EDA + AAP + LlamaStack + MCP | "Self-healing cluster with AI diagnostics" |
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

### 6. Agentic AI with LlamaStack + MCP

Deploy an AI agent that uses tools (MCP servers) to interact with external
systems -- execute Ansible job templates, update ServiceNow incidents, push
code to Git repos.

- Products: OpenShift AI (vLLM + LlamaStack), AAP (MCP server), external ITSM
- Key resources: `LlamaStackDistribution`, `InferenceService`, MCP Deployments
- LlamaStack provides: Responses API (agentic), vector store (RAG/memory),
  tool registration (MCP servers), embeddings
- Pattern: Playbook calls LlamaStack Responses API with system prompt + tools;
  LlamaStack routes inference to vLLM and tool calls to MCP servers

### 7. Self-Healing Cluster with AI

Closed-loop automation: alert -> diagnostics -> AI analysis -> remediation.

- Products: OpenShift (monitoring), AAP (EDA + workflows), OpenShift AI (LlamaStack + vLLM)
- Flow: Prometheus alert -> Alertmanager webhook -> EDA -> AAP workflow ->
  gather diagnostics -> query vector KB -> invoke AI (new or known path) ->
  generate/run remediation playbook -> store resolution in vector store
- MCP servers: AAP (manage job templates), ServiceNow (update incidents),
  Git (push remediation playbooks)

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

## LlamaStack (Agentic AI Layer)

LlamaStack provides an orchestration layer on top of vLLM for building AI agents:

- **Responses API** -- agentic endpoint: send a system prompt + user message +
  tool definitions; LlamaStack routes inference to vLLM and tool calls to
  registered MCP servers
- **Vector I/O** -- built-in vector store (PostgreSQL + pgvector or FAISS) for
  RAG and memory; insert/query embeddings without external vector DB
- **Tool registration** -- register MCP servers by label; LlamaStack discovers
  and invokes them during agent turns
- **Embeddings** -- sentence-transformers for embedding generation (local, no GPU needed)

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

## Best Practices

- Use KServe single-model serving for LLMs (not ModelMesh)
- Use ModelMesh for many small models sharing GPU resources
- Store models in S3-compatible storage (ODF NooBaa or MinIO), not PVCs for large models
- Use `ServingRuntime` CRs to define reusable serving configurations
- Enable autoscaling on `InferenceService` for variable load demos
- Use TrustyAI from Day 1 -- monitoring should be part of the demo, not an afterthought
- Pin notebook image tags; do not use `latest` in demos
- For RAG demos, use PGVector (PostgreSQL extension) as the vector store for simplicity
- For agentic AI demos, use LlamaStack over raw vLLM API -- it handles tool
  calling, conversation state, and vector store integration
- Build MCP servers on UBI9 Python images; deploy as standard OCP workloads
- Reference `rh-certified-components` for all base images and operators

## Integration with Other Domains

| Domain | Integration Point |
|--------|-------------------|
| OpenShift | GPU Operator, Routes, ODF storage, Service Mesh for serving |
| Ansible | Automate RHOAI deployment, notebook provisioning, pipeline triggers |
| Middleware | Application layer for RAG (Quarkus/Camel), AMQ Streams for event-driven inference |
| Telco | Edge inference with ACM, network anomaly detection models |
| RHEL | Custom notebook images built on UBI9, GPU driver host config |

## Documentation References

- [OpenShift AI 3 Documentation](https://docs.redhat.com/en/documentation/red_hat_openshift_ai_self-managed/3/)
- [OpenShift AI on cloud services](https://docs.redhat.com/en/documentation/red_hat_openshift_ai_cloud_service/)
- [KServe Documentation](https://kserve.github.io/website/)
- [Kubeflow Pipelines SDK](https://www.kubeflow.org/docs/components/pipelines/)
- [NVIDIA GPU Operator on OCP](https://docs.nvidia.com/datacenter/cloud-native/openshift/latest/index.html)
- [vLLM Documentation](https://docs.vllm.ai/)

For detailed API reference and configuration examples, see
[openshift-ai-reference.md](openshift-ai-reference.md).
