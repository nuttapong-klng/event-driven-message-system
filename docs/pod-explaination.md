# Kubernetes Pod Definitions in This Project

This document explains which Kubernetes configurations in the `k8s/` directory result in the creation of pods.

## Resources That Define Pods

### 1. StatefulSet

- **File:** `03-postgres.yaml`
- **Kind:** `StatefulSet`
- **Name:** `postgres`
- **Purpose:** Deploys a PostgreSQL database. The StatefulSet manages the pod(s) for the database, including persistent storage.

### 2. Deployment

- **File:** `04-backend.yaml`
  - **Kind:** `Deployment`
    - **Name:** `backend` — Deploys the backend application as a pod.
    - **Name:** `consumer` — Deploys a consumer service as a pod.
- **File:** `05-frontend.yaml`
  - **Kind:** `Deployment`
    - **Name:** `frontend` — Deploys the frontend application as a pod.

### 3. Job

- **File:** `04-backend.yaml`
- **Kind:** `Job`
- **Name:** `init-job`
- **Purpose:** Runs a one-time initialization job in a pod.

### 4. Custom Resource (Strimzi Kafka)

- **File:** `02-kafka-cluster.yaml`
- **Kind:** `Kafka` (Strimzi Custom Resource)
- **Name:** `kafka-cluster`
- **Purpose:** This custom resource, when processed by the Strimzi operator, results in the creation of multiple pods for Kafka brokers, Zookeeper, and entity operators.

---

## Summary Table

| File                  | Kind        | Name          | Results in Pod(s)? | Purpose                     |
| --------------------- | ----------- | ------------- | ------------------ | --------------------------- |
| 03-postgres.yaml      | StatefulSet | postgres      | Yes                | PostgreSQL database         |
| 04-backend.yaml       | Deployment  | backend       | Yes                | Backend app                 |
| 04-backend.yaml       | Deployment  | consumer      | Yes                | Consumer service            |
| 04-backend.yaml       | Job         | init-job      | Yes                | Initialization job          |
| 05-frontend.yaml      | Deployment  | frontend      | Yes                | Frontend app                |
| 02-kafka-cluster.yaml | Kafka (CR)  | kafka-cluster | Yes (via operator) | Kafka, Zookeeper, operators |

---

## Notes

- `Service`, `ConfigMap`, and `Secret` resources do **not** directly create pods.
- The Strimzi operator (from `01-strimzi-operator.yaml`) is deployed via Helm and creates its own pods, but the actual pod definitions for Kafka/Zookeeper are managed by the operator based on the custom resources you provide (like the `Kafka` resource).
- The `kind-config.yaml` file is for cluster setup and does not define pods.
