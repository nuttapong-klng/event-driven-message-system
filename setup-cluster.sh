#!/bin/bash

# Create Kind cluster with port mappings:
kind create cluster --name event-driven-message-system --config k8s/kind-config.yaml

# Create the namespace:
kubectl apply -f k8s/00-namespace.yaml

# Install Strimzi Operator:
helm repo add strimzi https://strimzi.io/charts/
helm repo update

# Install Strimzi Operator
helm install strimzi-kafka-operator strimzi/strimzi-kafka-operator \
  --namespace strimzi-system \
  --create-namespace \
  --version 0.45.0 \
  --set watchNamespaces={event-driven-message-system} \
  --set resources.requests.memory=384Mi \
  --set resources.requests.cpu=200m \
  --set resources.limits.memory=768Mi \
  --set resources.limits.cpu=1000m

# Wait for the Strimzi operator to be ready:
kubectl wait --for=condition=ready pod -l name=strimzi-cluster-operator -n strimzi-system --timeout=60s

# Deploy Kafka cluster:
kubectl apply -f k8s/02-kafka-cluster.yaml
# Wait for Kafka cluster to be ready
echo "Waiting for Kafka cluster to be ready..."
kubectl wait --for=condition=ready pod -l strimzi.io/cluster=kafka-cluster -n event-driven-message-system --timeout=300s

# Deploy PostgreSQL:
kubectl apply -f k8s/03-postgres.yaml
# Wait for PostgreSQL to be ready
echo "Waiting for PostgreSQL to be ready..."
kubectl wait --for=condition=ready pod -l app=postgres -n event-driven-message-system --timeout=120s

# Deploy backend services:
kubectl apply -f k8s/04-backend.yaml
# Wait for backend services to be ready
echo "Waiting for backend services to be ready..."
kubectl wait --for=condition=ready pod -l app=backend -n event-driven-message-system --timeout=120s
kubectl wait --for=condition=ready pod -l app=consumer -n event-driven-message-system --timeout=120s

# Deploy frontend:
kubectl apply -f k8s/05-frontend.yaml
# Wait for frontend to be ready
echo "Waiting for frontend to be ready..."
kubectl wait --for=condition=ready pod -l app=frontend -n event-driven-message-system --timeout=120s

echo "All services are deployed and ready!"
