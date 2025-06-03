# Production Kubernetes Setup

This directory contains the production-grade Kubernetes configurations using Strimzi Kafka Operator.

## Prerequisites

- Kubernetes cluster with version >= 1.19
- kubectl installed and configured
- Helm v3 installed

## Installation Steps

1. First, create the namespaces:
```bash
kubectl apply -f 00-namespace.yaml
kubectl apply -f 01-strimzi-operator.yaml
```

2. Install Strimzi Operator using Helm:
```bash
# Add Strimzi Helm repository
helm repo add strimzi https://strimzi.io/charts/
helm repo update

# Install Strimzi Operator
helm install strimzi-kafka-operator strimzi/strimzi-kafka-operator \
  --namespace strimzi-system \
  --version 0.45.0 \
  --set watchNamespaces={message-system-prod} \
  --set resources.requests.memory=384Mi \
  --set resources.requests.cpu=200m \
  --set resources.limits.memory=768Mi \
  --set resources.limits.cpu=1000m
```

3. Wait for the Strimzi operator to be ready:
```bash
kubectl wait --for=condition=ready pod -l name=strimzi-cluster-operator -n strimzi-system --timeout=300s
```

4. Deploy Kafka cluster:
```bash
kubectl apply -f 02-kafka-cluster.yaml
```

5. Wait for Kafka cluster to be ready (this may take a few minutes):
```bash
kubectl wait kafka/kafka-cluster --for=condition=Ready --timeout=300s -n message-system-prod
```

6. Deploy PostgreSQL:
```bash
kubectl apply -f 03-postgres.yaml
```

7. Wait for PostgreSQL to be ready:
```bash
kubectl wait --for=condition=ready pod -l app=postgres -n message-system-prod --timeout=300s
```

8. Deploy backend services:
```bash
kubectl apply -f 04-backend.yaml
```

9. Deploy frontend:
```bash
kubectl apply -f 05-frontend.yaml
```

10. Deploy ingress (requires nginx-ingress and cert-manager to be installed):
```bash
kubectl apply -f 06-ingress.yaml
```

## Prerequisites for Ingress

Before deploying the ingress, make sure you have:

1. NGINX Ingress Controller installed:
```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install nginx-ingress ingress-nginx/ingress-nginx
```

2. cert-manager installed for SSL certificates:
```bash
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.13.0 \
  --set installCRDs=true
```

## Monitoring

The Kafka cluster is configured with metrics enabled. To view these metrics:

1. Install Prometheus and Grafana:
```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace
```

2. Import the Strimzi Kafka dashboard in Grafana.

## Cleanup

To remove all resources:
```bash
kubectl delete -f 06-ingress.yaml
kubectl delete -f 05-frontend.yaml
kubectl delete -f 04-backend.yaml
kubectl delete -f 03-postgres.yaml
kubectl delete -f 02-kafka-cluster.yaml
helm uninstall strimzi-kafka-operator -n strimzi-system
kubectl delete -f 01-strimzi-operator.yaml
kubectl delete -f 00-namespace.yaml
``` 