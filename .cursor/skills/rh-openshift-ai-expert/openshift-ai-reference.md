# OpenShift AI Reference

Detailed API reference, CRD specifications, and configuration patterns for
Red Hat OpenShift AI 3.

## RHOAI Operator Installation

### DataScienceCluster CR

The top-level CR that controls which RHOAI components are enabled:

```yaml
apiVersion: datasciencecluster.opendatahub.io/v1
kind: DataScienceCluster
metadata:
  name: default-dsc
spec:
  components:
    codeflare:
      managementState: Managed
    dashboard:
      managementState: Managed
    datasciencepipelines:
      managementState: Managed
    kserve:
      managementState: Managed
      serving:
        ingressGateway:
          certificate:
            type: SelfSigned
        managementState: Managed
        name: knative-serving
    modelmeshserving:
      managementState: Managed
    ray:
      managementState: Managed
    trustyai:
      managementState: Managed
    workbenches:
      managementState: Managed
    kueue:
      managementState: Managed
    modelregistry:
      managementState: Managed
```

### DSCInitialization

Pre-requisite CR that sets up shared resources:

```yaml
apiVersion: dscinitialization.opendatahub.io/v1
kind: DSCInitialization
metadata:
  name: default-dsci
spec:
  applicationsNamespace: redhat-ods-applications
  monitoring:
    managementState: Managed
    namespace: redhat-ods-monitoring
  serviceMesh:
    controlPlane:
      metricsCollection: Istio
      name: data-science-smcp
      namespace: istio-system
    managementState: Managed
  trustedCABundle:
    managementState: Managed
```

## Data Science Projects

Data Science Projects map to OpenShift namespaces with RHOAI labels:

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: my-ds-project
  labels:
    opendatahub.io/dashboard: "true"
  annotations:
    openshift.io/description: "ML project for demo"
    openshift.io/display-name: "My DS Project"
```

## Notebooks

### Notebook CR

```yaml
apiVersion: kubeflow.org/v1
kind: Notebook
metadata:
  name: my-notebook
  namespace: my-ds-project
  labels:
    opendatahub.io/dashboard: "true"
  annotations:
    notebooks.opendatahub.io/inject-oauth: "true"
    opendatahub.io/image-display-name: "PyTorch"
spec:
  template:
    spec:
      containers:
        - name: my-notebook
          image: image-registry.openshift-image-registry.svc:5000/redhat-ods-applications/pytorch:2024.1
          resources:
            requests:
              cpu: "1"
              memory: 8Gi
              nvidia.com/gpu: "1"
            limits:
              cpu: "2"
              memory: 16Gi
              nvidia.com/gpu: "1"
          volumeMounts:
            - name: notebook-data
              mountPath: /opt/app-root/src
      volumes:
        - name: notebook-data
          persistentVolumeClaim:
            claimName: my-notebook-data
```

### Custom Notebook Image

Register a custom image via ImageStream:

```yaml
apiVersion: image.openshift.io/v1
kind: ImageStream
metadata:
  name: custom-notebook
  namespace: redhat-ods-applications
  labels:
    opendatahub.io/notebook-image: "true"
  annotations:
    opendatahub.io/notebook-image-name: "Custom ML Notebook"
    opendatahub.io/notebook-image-desc: "Custom image with extra libraries"
spec:
  lookupPolicy:
    local: true
  tags:
    - name: "1.0"
      from:
        kind: DockerImage
        name: quay.io/myorg/custom-notebook:1.0
```

## Data Science Pipelines

### DataSciencePipelinesApplication CR

```yaml
apiVersion: datasciencepipelinesapplications.opendatahub.io/v1alpha1
kind: DataSciencePipelinesApplication
metadata:
  name: dspa
  namespace: my-ds-project
spec:
  apiServer:
    deploy: true
    enableSamplePipeline: false
  database:
    mariaDB:
      deploy: true
      pipelineDBName: mlpipeline
      pvcSize: 10Gi
  objectStorage:
    externalStorage:
      bucket: pipeline-artifacts
      host: s3.openshift-storage.svc
      port: ""
      s3CredentialsSecret:
        accessKey: AWS_ACCESS_KEY_ID
        secretKey: AWS_SECRET_ACCESS_KEY
        secretName: aws-connection-pipelines
      scheme: https
  persistenceAgent:
    deploy: true
  scheduledWorkflow:
    deploy: true
```

### Pipeline Example (Kubeflow Pipelines SDK v2)

```python
from kfp import dsl, compiler

@dsl.component(base_image="registry.access.redhat.com/ubi9/python-311:latest")
def preprocess(data_path: str) -> str:
    import pandas as pd
    df = pd.read_csv(data_path)
    processed_path = "/tmp/processed.csv"
    df.dropna().to_csv(processed_path, index=False)
    return processed_path

@dsl.component(base_image="registry.access.redhat.com/ubi9/python-311:latest",
               packages_to_install=["scikit-learn", "joblib"])
def train(data_path: str) -> str:
    import pandas as pd
    from sklearn.ensemble import RandomForestClassifier
    import joblib
    df = pd.read_csv(data_path)
    X, y = df.iloc[:, :-1], df.iloc[:, -1]
    model = RandomForestClassifier().fit(X, y)
    model_path = "/tmp/model.joblib"
    joblib.dump(model, model_path)
    return model_path

@dsl.pipeline(name="training-pipeline")
def training_pipeline(data_path: str = "s3://data/input.csv"):
    preprocess_task = preprocess(data_path=data_path)
    train_task = train(data_path=preprocess_task.output)

compiler.Compiler().compile(training_pipeline, "pipeline.yaml")
```

## Model Serving

### KServe Single-Model Serving

Full InferenceService with autoscaling and canary:

```yaml
apiVersion: serving.kserve.io/v1beta1
kind: InferenceService
metadata:
  name: llm-serving
  namespace: my-ds-project
  annotations:
    serving.kserve.io/deploymentMode: RawDeployment
    serving.knative.openshift.io/enablePassthrough: "true"
spec:
  predictor:
    minReplicas: 1
    maxReplicas: 3
    scaleTarget: 2
    scaleMetric: concurrency
    model:
      modelFormat:
        name: vLLM
      runtime: vllm-runtime
      storageUri: s3://models/granite-7b
      resources:
        requests:
          cpu: "4"
          memory: 24Gi
          nvidia.com/gpu: "1"
        limits:
          cpu: "8"
          memory: 48Gi
          nvidia.com/gpu: "1"
    tolerations:
      - key: nvidia.com/gpu
        operator: Exists
        effect: NoSchedule
```

### ModelMesh Multi-Model Serving

```yaml
apiVersion: serving.kserve.io/v1beta1
kind: InferenceService
metadata:
  name: sklearn-model
  namespace: my-ds-project
  annotations:
    serving.kserve.io/deploymentMode: ModelMesh
spec:
  predictor:
    model:
      modelFormat:
        name: sklearn
      runtime: mlserver-1.x
      storageUri: s3://models/sklearn-iris
```

### ServingRuntime for vLLM (full)

```yaml
apiVersion: serving.kserve.io/v1alpha1
kind: ServingRuntime
metadata:
  name: vllm-runtime
  namespace: my-ds-project
  annotations:
    opendatahub.io/apiProtocol: REST
    opendatahub.io/template-display-name: vLLM ServingRuntime
spec:
  annotations:
    prometheus.io/path: /metrics
    prometheus.io/port: "8080"
  multiModel: false
  supportedModelFormats:
    - autoSelect: true
      name: vLLM
  containers:
    - name: kserve-container
      image: quay.io/modh/vllm:stable
      command:
        - python
        - -m
        - vllm.entrypoints.openai.api_server
      args:
        - --port=8080
        - --model=/mnt/models
        - --served-model-name={{.Name}}
        - --dtype=auto
        - --max-model-len=4096
      env:
        - name: HF_HOME
          value: /tmp/hf_home
      ports:
        - containerPort: 8080
          name: http
          protocol: TCP
      resources:
        requests:
          cpu: "2"
          memory: 8Gi
        limits:
          cpu: "4"
          memory: 16Gi
```

## Model Registry

```yaml
apiVersion: modelregistry.opendatahub.io/v1alpha1
kind: ModelRegistry
metadata:
  name: model-registry
  namespace: my-ds-project
spec:
  grpc:
    port: 9090
  rest:
    port: 8080
  mysql:
    host: mysql.my-ds-project.svc
    port: 3306
    database: model_registry
    username: mlmd
    passwordSecret:
      name: mysql-secret
      key: password
```

## TrustyAI

### TrustyAIService CR

```yaml
apiVersion: trustyai.opendatahub.io/v1alpha1
kind: TrustyAIService
metadata:
  name: trustyai-service
  namespace: my-ds-project
spec:
  storage:
    format: PVC
    folder: /data
    size: 5Gi
  data:
    filename: data.csv
    format: CSV
  metrics:
    schedule: 5m
```

### Bias Metrics Request

```bash
curl -X POST https://trustyai-route/metrics/spd/request \
  -H "Content-Type: application/json" \
  -d '{
    "modelId": "my-model",
    "protectedAttribute": "gender",
    "favorableOutcome": 1,
    "outcomeName": "prediction",
    "privilegedAttribute": 1,
    "unprivilegedAttribute": 0
  }'
```

## Distributed Training

### RayCluster for Distributed Training

```yaml
apiVersion: ray.io/v1
kind: RayCluster
metadata:
  name: training-cluster
  namespace: my-ds-project
spec:
  headGroupSpec:
    rayStartParams:
      dashboard-host: "0.0.0.0"
    template:
      spec:
        containers:
          - name: ray-head
            image: quay.io/modh/ray:2.35.0-py311-cu121
            resources:
              requests:
                cpu: "2"
                memory: 8Gi
              limits:
                cpu: "4"
                memory: 16Gi
  workerGroupSpecs:
    - replicas: 2
      minReplicas: 1
      maxReplicas: 4
      groupName: gpu-workers
      rayStartParams: {}
      template:
        spec:
          containers:
            - name: ray-worker
              image: quay.io/modh/ray:2.35.0-py311-cu121
              resources:
                requests:
                  cpu: "4"
                  memory: 16Gi
                  nvidia.com/gpu: "1"
                limits:
                  cpu: "8"
                  memory: 32Gi
                  nvidia.com/gpu: "1"
          tolerations:
            - key: nvidia.com/gpu
              operator: Exists
              effect: NoSchedule
```

### RayJob for Training

```yaml
apiVersion: ray.io/v1
kind: RayJob
metadata:
  name: fine-tune-llm
  namespace: my-ds-project
spec:
  entrypoint: python train.py --model granite-7b --epochs 3
  runtimeEnvYAML: |
    working_dir: "s3://training/scripts/"
    pip:
      - torch
      - transformers
      - peft
  rayClusterSpec:
    # ... same as RayCluster spec above
  submitterPodTemplate:
    spec:
      containers:
        - name: submitter
          image: quay.io/modh/ray:2.35.0-py311-cu121
```

## S3 Storage Configuration

Most RHOAI components need S3-compatible storage. Using ODF NooBaa:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: aws-connection-models
  namespace: my-ds-project
  labels:
    opendatahub.io/dashboard: "true"
    opendatahub.io/managed: "true"
  annotations:
    opendatahub.io/connection-type: s3
    openshift.io/display-name: "Model Storage"
type: Opaque
stringData:
  AWS_ACCESS_KEY_ID: "<access-key>"
  AWS_SECRET_ACCESS_KEY: "<secret-key>"
  AWS_DEFAULT_ENDPOINT: "https://s3.openshift-storage.svc"
  AWS_DEFAULT_REGION: "us-east-1"
  AWS_S3_BUCKET: "models"
  AWS_S3_ENDPOINT: "https://s3.openshift-storage.svc"
```

## GPU Operator Setup

### NVIDIA GPU Operator Subscription

```yaml
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: gpu-operator-certified
  namespace: nvidia-gpu-operator
spec:
  channel: v24.6
  name: gpu-operator-certified
  source: certified-operators
  sourceNamespace: openshift-marketplace
  installPlanApproval: Automatic
```

### ClusterPolicy (NVIDIA)

```yaml
apiVersion: nvidia.com/v1
kind: ClusterPolicy
metadata:
  name: gpu-cluster-policy
spec:
  operator:
    defaultRuntime: crio
  driver:
    enabled: true
    repoConfig:
      configMapName: ""
  toolkit:
    enabled: true
  devicePlugin:
    enabled: true
  dcgmExporter:
    enabled: true
  gfd:
    enabled: true
  migManager:
    enabled: true
  nodeStatusExporter:
    enabled: true
```

## CLI Commands for Demo Workflows

```bash
# Check RHOAI operator status
oc get DataScienceCluster -A

# List notebooks
oc get notebooks -n my-ds-project

# Check inference services
oc get inferenceservice -n my-ds-project

# Get inference endpoint URL
oc get inferenceservice my-llm -n my-ds-project -o jsonpath='{.status.url}'

# Test vLLM inference (OpenAI-compatible)
curl -k "$(oc get inferenceservice my-llm -o jsonpath='{.status.url}')/v1/completions" \
  -H "Content-Type: application/json" \
  -d '{"model": "my-llm", "prompt": "Red Hat OpenShift is", "max_tokens": 100}'

# Check pipeline runs
oc get pipelineruns -n my-ds-project

# Monitor GPU utilization
oc exec -n nvidia-gpu-operator $(oc get pods -n nvidia-gpu-operator -l app=nvidia-dcgm-exporter -o name | head -1) -- nvidia-smi

# Check TrustyAI metrics
oc get route trustyai-service -n my-ds-project -o jsonpath='{.spec.host}'

# List model registry entries
curl -s "http://$(oc get route model-registry -n my-ds-project -o jsonpath='{.spec.host}')/api/model_registry/v1alpha3/registered_models" | jq

# Check Ray cluster status
oc get raycluster -n my-ds-project
```

## LlamaStack Distribution

### LlamaStackDistribution CR

Deploys a LlamaStack server that connects to vLLM for inference and PostgreSQL
for vector storage:

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
      name: llama-stack
      port: 8321
      env:
        - name: VLLM_URL
          value: "http://my-model-predictor.rhoai-project.svc:8000/v1"
        - name: INFERENCE_MODEL
          value: "granite-3-1-8b-starter"
        - name: VLLM_TLS_VERIFY
          value: "false"
        - name: POSTGRES_HOST
          value: "llamastack-postgres.rhoai-project.svc.cluster.local"
        - name: POSTGRES_PORT
          value: "5432"
        - name: POSTGRES_DB
          value: "llamastack"
        - name: POSTGRES_USER
          value: "llamastack"
        - name: POSTGRES_PASSWORD
          valueFrom:
            secretKeyRef:
              name: llamastack-postgres-secret
              key: password
        - name: ENABLE_SENTENCE_TRANSFORMERS
          value: "true"
        - name: EMBEDDING_PROVIDER
          value: "sentence-transformers"
      resources:
        requests:
          cpu: "250m"
          memory: "500Mi"
        limits:
          cpu: "4"
          memory: "8Gi"
    storage:
      size: "5Gi"
```

### LlamaStack API Endpoints

| Endpoint | Purpose |
|----------|---------|
| `POST /v1/responses` | Agentic completion with tool use |
| `POST /v1/inference/chat_completion` | Direct chat completion |
| `POST /v1/vector-io/insert` | Insert documents into vector bank |
| `POST /v1/vector-io/query` | Query vector bank for similar documents |
| `GET /v1/models` | List available models |
| `GET /v1/health` | Health check |

### Calling LlamaStack from Ansible

```yaml
- name: Invoke AI analysis via LlamaStack Responses API
  ansible.builtin.uri:
    url: "{{ llamastack_url }}/v1/responses"
    method: POST
    body_format: json
    body:
      model: "{{ inference_model }}"
      input: "{{ system_prompt }}"
      tools:
        - type: mcp
          server_label: aap
        - type: mcp
          server_label: servicenow
        - type: mcp
          server_label: git
      stream: false
    timeout: 300
  register: ai_response
```

### Vector Store Operations

Insert a resolution into the knowledge base:

```yaml
- name: Store incident resolution in vector store
  ansible.builtin.uri:
    url: "{{ llamastack_url }}/v1/vector-io/insert"
    method: POST
    body_format: json
    body:
      bank_id: "incident-resolutions"
      chunks:
        - content: "{{ resolution_json | to_json }}"
          metadata:
            alert_name: "{{ alert_name }}"
            incident_number: "{{ snow_incident_number }}"
```

Query for similar past incidents:

```yaml
- name: Check knowledge base for similar incidents
  ansible.builtin.uri:
    url: "{{ llamastack_url }}/v1/vector-io/query"
    method: POST
    body_format: json
    body:
      bank_id: "incident-resolutions"
      query: "{{ alert_name }}: {{ alert_description }}"
      params:
        max_chunks: 3
  register: kb_response
```

## MCP Servers on OpenShift

### Containerfile Pattern (UBI9 Python)

```dockerfile
FROM registry.access.redhat.com/ubi9/python-311:latest
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
EXPOSE 8080
CMD ["python", "-m", "my_mcp_server", "--port", "8080", "--transport", "streamable-http"]
```

### MCP Server Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: servicenow-mcp
  namespace: my-agent-ns
spec:
  replicas: 1
  selector:
    matchLabels:
      app: servicenow-mcp
  template:
    metadata:
      labels:
        app: servicenow-mcp
    spec:
      containers:
        - name: mcp-server
          image: quay.io/myorg/servicenow-mcp:latest
          ports:
            - containerPort: 8080
          envFrom:
            - secretRef:
                name: servicenow-credentials
---
apiVersion: v1
kind: Service
metadata:
  name: servicenow-mcp
  namespace: my-agent-ns
spec:
  selector:
    app: servicenow-mcp
  ports:
    - port: 8080
      targetPort: 8080
```

## Hardware Profiles

Hardware profiles define GPU resource templates for notebooks and serving:

```yaml
apiVersion: dashboard.opendatahub.io/v1alpha1
kind: HardwareProfile
metadata:
  name: gpu-large
  namespace: redhat-ods-applications
spec:
  displayName: "Large GPU (L4/A10)"
  description: "24GB VRAM GPU for LLM serving"
  enabled: true
  identifiers:
    - displayName: "CPU"
      identifier: cpu
      defaultCount: 4
      maxCount: 8
      minCount: 2
    - displayName: "Memory"
      identifier: memory
      defaultCount: 24Gi
      maxCount: 48Gi
      minCount: 16Gi
    - displayName: "NVIDIA GPU"
      identifier: nvidia.com/gpu
      defaultCount: 1
      maxCount: 2
      minCount: 1
  tolerations:
    - key: nvidia.com/gpu
      operator: Exists
      effect: NoSchedule
```

## Documentation

- [RHOAI 3 Product Documentation](https://docs.redhat.com/en/documentation/red_hat_openshift_ai_self-managed/3/)
- [RHOAI Release Notes](https://docs.redhat.com/en/documentation/red_hat_openshift_ai_self-managed/3/html/release_notes/)
- [Serving LLMs on RHOAI](https://docs.redhat.com/en/documentation/red_hat_openshift_ai_self-managed/3/html/serving_models/)
- [Data Science Pipelines](https://docs.redhat.com/en/documentation/red_hat_openshift_ai_self-managed/3/html/working_with_data_science_pipelines/)
- [Distributed Workloads](https://docs.redhat.com/en/documentation/red_hat_openshift_ai_self-managed/3/html/working_with_distributed_workloads/)
- [TrustyAI](https://docs.redhat.com/en/documentation/red_hat_openshift_ai_self-managed/3/html/monitoring_data_science_models/)
- [LlamaStack Documentation](https://llama-stack.readthedocs.io/)
