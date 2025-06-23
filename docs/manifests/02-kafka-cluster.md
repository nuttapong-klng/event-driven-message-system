# Explanation of `k8s/02-kafka-cluster.yaml`

This document explains the purpose and content of the file `k8s/02-kafka-cluster.yaml`, which is responsible for deploying a Kafka cluster (and related resources) using the Strimzi Operator in your Kubernetes environment.

---

## Purpose of the File

The `k8s/02-kafka-cluster.yaml` manifest defines a single-node Apache Kafka cluster, its Zookeeper ensemble, and a ConfigMap for Kafka metrics. This file is intended to be applied in a development or test environment, providing a minimal but functional Kafka setup managed by Strimzi.

---

## Structure and Content

### 1. Kafka Cluster Resource

```yaml
apiVersion: kafka.strimzi.io/v1beta2
kind: Kafka
metadata:
  name: kafka-cluster
  namespace: event-driven-message-system
spec:
  kafka:
    version: 3.9.0
    replicas: 1
    listeners:
      - name: plain
        port: 9092
        type: internal
        tls: false
    config:
      offsets.topic.replication.factor: 1
      transaction.state.log.replication.factor: 1
      transaction.state.log.min.isr: 1
      default.replication.factor: 1
      min.insync.replicas: 1
      inter.broker.protocol.version: "3.9"
    storage:
      type: jbod
      volumes:
        - id: 0
          type: persistent-claim
          size: 1Gi
          deleteClaim: false
    resources:
      requests:
        memory: 512Mi
        cpu: 200m
      limits:
        memory: 1Gi
        cpu: 500m
  zookeeper:
    replicas: 1
    storage:
      type: persistent-claim
      size: 1Gi
      deleteClaim: false
    resources:
      requests:
        memory: 256Mi
        cpu: 100m
      limits:
        memory: 512Mi
        cpu: 300m
  entityOperator:
    topicOperator:
      resources:
        requests:
          memory: 128Mi
          cpu: 100m
        limits:
          memory: 256Mi
          cpu: 200m
    userOperator:
      resources:
        requests:
          memory: 128Mi
          cpu: 100m
        limits:
          memory: 256Mi
          cpu: 200m
```

- **Purpose:** Defines a Kafka cluster named `kafka-cluster` in the `event-driven-message-system` namespace.
- **Kafka Section:**
  - **version:** Kafka version 3.9.0.
  - **replicas:** Single broker (for development/testing).
  - **listeners:** Exposes a non-TLS internal listener on port 9092.
  - **config:** Sets replication factors and protocol versions for a single-node setup.
  - **storage:** Uses persistent storage (1Gi) with JBOD configuration.
  - **resources:** Specifies resource requests and limits for the Kafka broker pod.
- **Zookeeper Section:**
  - **replicas:** Single Zookeeper node (sufficient for non-production use).
  - **storage:** Persistent storage (1Gi).
  - **resources:** Resource requests and limits for Zookeeper pod.
- **Entity Operator:**
  - Deploys Topic and User Operators for automated topic/user management, with resource constraints.

### 2. Kafka Metrics ConfigMap

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: kafka-metrics
  namespace: event-driven-message-system
  labels:
    app: strimzi
data:
  kafka-metrics-config.yml: |
    lowercaseOutputName: true
    rules:
      - pattern: kafka.server<type=(.+), name=(.+), clientId=(.+), topic=(.+), partition=(.*)><>Value
        name: kafka_server_$1_$2
        type: GAUGE
        labels:
          clientId: "$3"
          topic: "$4"
          partition: "$5"
      - pattern: kafka.server<type=(.+), name=(.+), clientId=(.+), brokerHost=(.+), brokerPort=(.+)><>Value
        name: kafka_server_$1_$2
        type: GAUGE
        labels:
          clientId: "$3"
          broker: "$4:$5"
```

- **Purpose:** Provides a metrics configuration for Kafka, enabling Prometheus-compatible metrics scraping via Strimzi.
- **Details:**
  - Defines rules for extracting and labeling Kafka server metrics.
  - Intended for integration with monitoring tools.

---

## Why This File Is Important

- **Deploys a Kafka Cluster:** Sets up a minimal, single-node Kafka cluster suitable for development or testing.
- **Managed by Strimzi:** Leverages the Strimzi Operator for lifecycle management and automation.
- **Metrics Ready:** Includes a ConfigMap for exposing Kafka metrics, supporting observability best practices.
- **Customizable:** Resource requests/limits and storage can be tuned for different environments.

---

For more details on customizing your Kafka cluster or metrics, refer to the [Strimzi documentation](https://strimzi.io/docs/), or ask for further explanation.
