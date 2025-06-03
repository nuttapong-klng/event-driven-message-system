# Production Kubernetes Setup
# 1. Create Kind cluster with port mappings:
kind create cluster --name message-system-prod --config kind-config.yaml

# 2. Create the namespace:
kubectl apply -f 00-namespace.yaml

#3. Install NGINX Ingress Controller:
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install nginx-ingress ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace \
  --set controller.service.type=NodePort \
  --set controller.hostPort.enabled=true \
  --set controller.service.nodePorts.http=31059 \
  --set controller.service.nodePorts.https=30914

# 4. Install cert-manager for SSL certificates:
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.13.0 \
  --set installCRDs=true

# 5. Create self-signed certificate issuer:
kubectl apply -f cluster-issuer.yaml

# 6. Install Strimzi Operator:
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

# 7. Wait for the Strimzi operator to be ready:
kubectl wait --for=condition=ready pod -l name=strimzi-cluster-operator -n strimzi-system --timeout=60s

# 8. Deploy Kafka cluster:
kubectl apply -f 02-kafka-cluster.yaml

# 9. Wait for Kafka cluster to be ready (this may take a few minutes):
# kubectl wait kafka/kafka-cluster --for=condition=Ready --timeout=60s -n message-system-prod

# 10. Deploy PostgreSQL:
kubectl apply -f 03-postgres.yaml

# 11. Wait for PostgreSQL to be ready:
# kubectl wait --for=condition=ready pod -l app=postgres -n message-system-prod --timeout=60s

# 12. Deploy backend services:
kubectl apply -f 04-backend.yaml

# 13. Deploy frontend:
kubectl apply -f 05-frontend.yaml

# 14. Deploy ingress:
kubectl apply -f 06-ingress.yaml
