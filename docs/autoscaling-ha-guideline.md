# Guideline: Autoscaling & High Availability (HA) for the Event-Driven Message System

This document provides practical steps and best practices to achieve autoscaling and high availability (HA) for your event-driven message system, based on the manifests in the `k8s/` directory.

---

## 1. General Principles

- **High Availability (HA):** Avoid single points of failure. Use multiple replicas, spread workloads across nodes, and use persistent storage.
- **Autoscaling:** Use Kubernetes Horizontal Pod Autoscaler (HPA) for stateless workloads, and cluster-aware/manual scaling for stateful components like Kafka and PostgreSQL.

---

## 2. Kafka (Strimzi Operator)

### High Availability

- **Brokers:** Set `replicas` for Kafka brokers to at least 3 in `02-kafka-cluster.yaml` for production HA.
- **Zookeeper:** Set Zookeeper replicas to at least 3.
- **Storage:** Use persistent volumes with replication and regular backups.
- **PodDisruptionBudgets:** Add PodDisruptionBudgets to ensure a minimum number of pods are always available during voluntary disruptions.

### Autoscaling

- **Kafka brokers do not support HPA** (due to stateful nature). Scale by increasing the `replicas` field in the Kafka custom resource.
- **Monitoring:** Use Strimzi's metrics and Prometheus to monitor broker load and plan scaling.

---

## 3. PostgreSQL

### High Availability

- **StatefulSet:** Use a StatefulSet with at least 2-3 replicas and configure streaming replication (primary/standby).
- **Operator:** Consider using a PostgreSQL operator (like Zalando or CrunchyData) for automated failover and backups.
- **Storage:** Use persistent volumes with backup and restore strategies.

### Autoscaling

- **Vertical Scaling:** Increase CPU/memory requests/limits as needed.
- **Horizontal Scaling:** Use read replicas for scaling reads (true horizontal scaling is complex for databases).

---

## 4. Backend & Frontend

### High Availability

- **Replicas:** In `04-backend.yaml` and `05-frontend.yaml`, set `replicas` in the Deployment spec to at least 2-3.
- **Readiness/Liveness Probes:** Ensure these are set so Kubernetes can detect and replace unhealthy pods.
- **PodDisruptionBudgets:** Add to ensure minimum availability during node maintenance.

### Autoscaling

- **Horizontal Pod Autoscaler (HPA):** Add an HPA resource for each Deployment:

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: backend-hpa
  namespace: event-driven-message-system
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: backend
  minReplicas: 2
  maxReplicas: 10
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 70
```

_Repeat for frontend and consumer deployments._

---

## 5. Node and Storage Considerations

- **Multi-node Cluster:** Run your cluster on at least 3 nodes for true HA.
- **Anti-affinity Rules:** Use `podAntiAffinity` to spread replicas across nodes.
- **StorageClass:** Use a StorageClass that supports replication and high availability.

---

## 6. Example: Adding HPA and PodDisruptionBudget

Add to your backend manifest (repeat for frontend/consumer):

```yaml
# Horizontal Pod Autoscaler
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: backend-hpa
  namespace: event-driven-message-system
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: backend
  minReplicas: 2
  maxReplicas: 10
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 70
---
# PodDisruptionBudget
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: backend-pdb
  namespace: event-driven-message-system
spec:
  minAvailable: 2
  selector:
    matchLabels:
      app: backend
```

---

## 7. Monitoring & Alerts

- Deploy Prometheus and Grafana for monitoring.
- Set up alerts for pod unavailability, high CPU/memory, and storage issues.

---

## 8. Documentation & Testing

- Document your scaling and HA strategy.
- Regularly test failover and scaling in a staging environment.

---

## Summary Table

| Component  | HA Recommendation        | Autoscaling Approach    |
| ---------- | ------------------------ | ----------------------- |
| Kafka      | 3+ brokers, PDB, PV      | Manual (edit replicas)  |
| PostgreSQL | StatefulSet, operator    | Vertical, read replicas |
| Backend    | 2+ replicas, PDB, probes | HPA (CPU/memory)        |
| Frontend   | 2+ replicas, PDB, probes | HPA (CPU/memory)        |

---
