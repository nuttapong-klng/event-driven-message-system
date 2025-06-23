# Step-by-Step Explanation of `setup-cluster.sh`

This document explains each step of the `setup-cluster.sh` script, which automates the setup of the event-driven message system Kubernetes environment. Each command or block is described in order, so you can understand what happens during the cluster setup process.

---

## 1. Create Kind Cluster

```bash
kind create cluster --name event-driven-message-system --config k8s/kind-config.yaml
```

- **Purpose:** Creates a local Kubernetes cluster using [Kind](https://kind.sigs.k8s.io/), with the name `event-driven-message-system` and configuration from `k8s/kind-config.yaml`. This sets up the foundation for running all other resources.

---

## 2. Create the Namespace

```bash
kubectl apply -f k8s/00-namespace.yaml
```

- **Purpose:** Applies the namespace manifest to create a dedicated namespace (`event-driven-message-system`) in the cluster. This isolates all related resources for better organization and management.

---

## 3. Install Strimzi Operator Helm Repository

```bash
helm repo add strimzi https://strimzi.io/charts/
helm repo update
```

- **Purpose:** Adds the official Strimzi Helm chart repository and updates the local Helm repo cache. This prepares Helm to install the Strimzi Kafka Operator.

---

## 4. Install Strimzi Kafka Operator

```bash
helm install strimzi-kafka-operator strimzi/strimzi-kafka-operator \
  --namespace strimzi-system \
  --create-namespace \
  --version 0.45.0 \
  --set watchNamespaces={event-driven-message-system} \
  --set resources.requests.memory=384Mi \
  --set resources.requests.cpu=200m \
  --set resources.limits.memory=768Mi \
  --set resources.limits.cpu=1000m
```

- **Purpose:** Installs the Strimzi Kafka Operator into the `strimzi-system` namespace using Helm. The operator will watch the `event-driven-message-system` namespace for Kafka resources. Resource requests and limits are set for efficient operation.

---

## 5. Wait for Strimzi Operator to be Ready

```bash
sleep 30
kubectl wait --for=condition=ready pod -l name=strimzi-cluster-operator -n strimzi-system --timeout=60s
```

- **Purpose:** Waits for the Strimzi operator pod to become ready before proceeding. This ensures the operator is fully running and able to manage Kafka resources.

---

## 6. Deploy Kafka Cluster

```bash
kubectl apply -f k8s/02-kafka-cluster.yaml
```

- **Purpose:** Deploys the Kafka cluster using the provided manifest. The Strimzi operator will create and manage the necessary Kafka and Zookeeper pods.

---

## 7. Deploy PostgreSQL

```bash
kubectl apply -f k8s/03-postgres.yaml
```

- **Purpose:** Deploys a PostgreSQL database instance in the cluster, as defined in the manifest.

---

## 8. Deploy Backend Services

```bash
kubectl apply -f k8s/04-backend.yaml
```

- **Purpose:** Deploys the backend application(s) for the event-driven message system.

---

## 9. Deploy Frontend

```bash
kubectl apply -f k8s/05-frontend.yaml
```

- **Purpose:** Deploys the frontend application for the system.

---

## 10. Wait for Application Pods to be Ready

```bash
sleep 30
kubectl wait --for=condition=ready pod -l app=frontend -n event-driven-message-system --timeout=120s
kubectl wait --for=condition=ready pod -l app=backend -n event-driven-message-system --timeout=120s
kubectl wait --for=condition=ready pod -l app=consumer -n event-driven-message-system --timeout=120s
```

- **Purpose:** Waits for the frontend, backend, and consumer pods to become ready in the `event-driven-message-system` namespace. This ensures all core components are running before the setup is considered complete.

---

## Summary

The `setup-cluster.sh` script automates the entire process of setting up a local Kubernetes environment for the event-driven message system, including cluster creation, namespace setup, operator installation, and deployment of all core services. Each step ensures that the environment is ready for development or testing.
