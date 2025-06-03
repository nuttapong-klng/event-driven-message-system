# Production Kubernetes Setup

This directory contains the production-grade Kubernetes configurations using Strimzi Kafka Operator and Kind cluster.

## Prerequisites

- Docker Desktop installed and running
- Kind (Kubernetes in Docker) installed
- kubectl installed and configured
- Helm v3 installed

## Installation Steps

1. Create Kind cluster with port mappings:
```bash
kind create cluster --name message-system-prod --config kind-config.yaml
```

2. Create the namespace:
```bash
kubectl apply -f 00-namespace.yaml
```

3. Install NGINX Ingress Controller:
```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install nginx-ingress ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace \
  --set controller.service.type=NodePort \
  --set controller.hostPort.enabled=true \
  --set controller.service.nodePorts.http=31059 \
  --set controller.service.nodePorts.https=30914
```

4. Install cert-manager for SSL certificates:
```bash
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.13.0 \
  --set installCRDs=true
```

5. Create self-signed certificate issuer:
```bash
kubectl apply -f cluster-issuer.yaml
```

6. Install Strimzi Operator:
```bash
helm repo add strimzi https://strimzi.io/charts/
helm repo update

# Install Strimzi Operator
helm install strimzi-kafka-operator strimzi/strimzi-kafka-operator \
  --namespace strimzi-system \
  --create-namespace \
  --version 0.45.0 \
  --set watchNamespaces={message-system-prod} \
  --set resources.requests.memory=384Mi \
  --set resources.requests.cpu=200m \
  --set resources.limits.memory=768Mi \
  --set resources.limits.cpu=1000m
```

7. Wait for the Strimzi operator to be ready:
```bash
kubectl wait --for=condition=ready pod -l name=strimzi-cluster-operator -n strimzi-system --timeout=60s
```

8. Deploy Kafka cluster:
```bash
kubectl apply -f 02-kafka-cluster.yaml
```

9. Wait for Kafka cluster to be ready (this may take a few minutes):
```bash
kubectl wait kafka/kafka-cluster --for=condition=Ready --timeout=60s -n message-system-prod
```

10. Deploy PostgreSQL:
```bash
kubectl apply -f 03-postgres.yaml
```

11. Wait for PostgreSQL to be ready:
```bash
kubectl wait --for=condition=ready pod -l app=postgres -n message-system-prod --timeout=60s
```

12. Deploy backend services:
```bash
kubectl apply -f 04-backend.yaml
```

13. Deploy frontend:
```bash
kubectl apply -f 05-frontend.yaml
```

14. Deploy ingress:
```bash
kubectl apply -f 06-ingress.yaml
```

## Accessing the Application

The application is accessible through:
- Frontend: https://localhost/
- API endpoints: https://localhost/api/

Note: Since we're using a self-signed certificate, you'll need to accept the security warning in your browser.

## Troubleshooting

To check the status of all pods:
```bash
kubectl get pods -n message-system-prod
```

To view logs of a specific pod:
```bash
kubectl logs -n message-system-prod <pod-name>
```

To check ingress status:
```bash
kubectl get ingress -n message-system-prod
```

To restart the ingress controller (if needed):
```bash
kubectl rollout restart deployment -n ingress-nginx nginx-ingress-ingress-nginx-controller
```

## Cleanup

To remove all resources:
```bash
kubectl delete -f 06-ingress.yaml
kubectl delete -f 05-frontend.yaml
kubectl delete -f 04-backend.yaml
kubectl delete -f 03-postgres.yaml
kubectl delete -f 02-kafka-cluster.yaml
helm uninstall strimzi-kafka-operator -n strimzi-system
helm uninstall nginx-ingress -n ingress-nginx
helm uninstall cert-manager -n cert-manager
kubectl delete -f cluster-issuer.yaml
kubectl delete -f 00-namespace.yaml
kind delete cluster --name message-system-prod
``` 