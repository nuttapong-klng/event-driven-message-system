# Event-Driven Message System - Kubernetes Setup

This guide explains how to run the Event-Driven Message System locally using Kind (Kubernetes in Docker).

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/)
- [Kind](https://kind.sigs.k8s.io/docs/user/quick-start/#installation)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)

## Setup Instructions

1. Create the Kind cluster:
```bash
kind create cluster --config kind-config.yaml
```

2. Create the namespace and deploy all components:
```bash
kubectl apply -f k8s/00-namespace.yaml
kubectl apply -f k8s/01-postgres.yaml
kubectl apply -f k8s/02-kafka.yaml
```

3. Wait for Kafka and PostgreSQL to be ready:
```bash
kubectl -n message-system wait --for=condition=ready pod -l app=kafka
kubectl -n message-system wait --for=condition=ready pod -l app=postgres
```

4. Deploy the backend services and frontend:
```bash
kubectl apply -f k8s/03-backend.yaml
kubectl apply -f k8s/04-frontend.yaml
```

5. Wait for all services to be ready:
```bash
kubectl -n message-system wait --for=condition=ready pod -l app=backend
kubectl -n message-system wait --for=condition=ready pod -l app=frontend
kubectl -n message-system wait --for=condition=ready pod -l app=consumer
```

## Accessing the Application

- Frontend: http://localhost:3000
- Backend API: http://localhost:8080

## Cleanup

To delete the cluster and all resources:
```bash
kind delete cluster --name message-system
```

## Troubleshooting

To check the status of all pods:
```bash
kubectl -n message-system get pods
```

To view logs of a specific pod:
```bash
kubectl -n message-system logs <pod-name>
``` 