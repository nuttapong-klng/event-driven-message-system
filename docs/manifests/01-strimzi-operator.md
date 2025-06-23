# ⚠️ IMPORTANT REMARK

> **❗ The file `k8s/01-strimzi-operator.yaml` is NOT used in the `setup-cluster.sh` script.**  
> The Strimzi Kafka Operator is installed directly using Helm commands in the script.  
> This manifest is intended for use with FluxCD or GitOps workflows, not for direct application in the provided setup script.

This document explains the purpose and content of the file `k8s/01-strimzi-operator.yaml`, which is responsible for deploying the Strimzi Kafka Operator in your Kubernetes cluster using FluxCD and Helm.

---

## Purpose of the File

The `k8s/01-strimzi-operator.yaml` manifest sets up the Strimzi Kafka Operator, which manages Apache Kafka clusters on Kubernetes. It uses FluxCD for GitOps-based deployment and Helm for package management. This operator is essential for running and managing Kafka resources in a declarative, automated way.

---

## Structure and Content

### 1. Namespace Definition

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: strimzi-system
  labels:
    env: production
```

- **Purpose:** Creates a dedicated namespace (`strimzi-system`) for Strimzi resources, labeled for the production environment.

### 2. HelmRepository Resource

```yaml
apiVersion: source.toolkit.fluxcd.io/v1beta2
kind: HelmRepository
metadata:
  name: strimzi
  namespace: strimzi-system
spec:
  interval: 1h
  url: https://strimzi.io/charts/
```

- **Purpose:** Registers the official Strimzi Helm chart repository with FluxCD, enabling automated chart retrieval and updates every hour.

### 3. HelmRelease Resource

```yaml
apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
metadata:
  name: strimzi-kafka-operator
  namespace: strimzi-system
spec:
  interval: 1h
  chart:
    spec:
      chart: strimzi-kafka-operator
      version: "0.39.0"
      sourceRef:
        kind: HelmRepository
        name: strimzi
        namespace: strimzi-system
  values:
    watchNamespaces:
      - event-driven-message-system
    resources:
      requests:
        memory: 384Mi
        cpu: 200m
      limits:
        memory: 768Mi
        cpu: 1000m
```

- **Purpose:** Instructs FluxCD to install and manage the Strimzi Kafka Operator via Helm.
- **Chart:** Specifies the chart name and version from the registered repository.
- **watchNamespaces:** Configures the operator to monitor the `event-driven-message-system` namespace for Kafka resources.
- **resources:** Sets resource requests and limits for the operator pod to ensure efficient and controlled resource usage.

---

## Why This File Is Important

- **Enables Kafka Management:** Deploys the Strimzi Kafka Operator, which is required to create and manage Kafka clusters and topics in Kubernetes.
- **GitOps Workflow:** Integrates with FluxCD for automated, declarative infrastructure management.
- **Resource Isolation:** Uses a dedicated namespace for better security and organization.
- **Custom Configuration:** Allows fine-tuning of resource usage and operator behavior.

---

For more details on how the Strimzi operator works or how to customize its deployment, refer to the [Strimzi documentation](https://strimzi.io/docs/), or ask for further explanation.
