# Explanation of `k8s/kind-config.yaml`

This document explains the purpose and content of the file `k8s/kind-config.yaml`, which is used to configure a local Kubernetes cluster with [Kind (Kubernetes in Docker)](https://kind.sigs.k8s.io/).

---

## Purpose of the File

The `kind-config.yaml` file defines the configuration for a local Kubernetes cluster created with Kind. It specifies the cluster name, node roles, port mappings, and storage mounts. This setup is essential for running the event-driven message system locally, enabling development and testing in an environment that closely mimics production Kubernetes.

---

## Structure and Content

### 1. Cluster Metadata

```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: event-driven-message-system
```

- **kind**: Declares this resource as a Kind cluster configuration.
- **apiVersion**: Specifies the Kind configuration API version.
- **name**: Sets the cluster's name to `event-driven-message-system` for easy identification.

### 2. Node Definition

```yaml
nodes:
  - role: control-plane
    image: kindest/node:v1.27.3
```

- **nodes**: Lists the nodes in the cluster. Here, a single control-plane node is defined.
- **role**: Sets the node as the control-plane (master) node.
- **image**: Specifies the node image version (Kubernetes v1.27.3).

### 3. Extra Port Mappings

```yaml
extraPortMappings:
  - containerPort: 30080
    hostPort: 8080
    protocol: TCP
  - containerPort: 30090
    hostPort: 3000
    protocol: TCP
```

- **extraPortMappings**: Forwards ports from the Kind node to the host machine:
  - Maps container port 30080 to host port 8080 (for backend/API access).
  - Maps container port 30090 to host port 3000 (for frontend access).
  - Both use the TCP protocol.

### 4. Extra Mounts

```yaml
extraMounts:
  - hostPath: /tmp/strimzi-data
    containerPath: /var/lib/strimzi
```

- **extraMounts**: Mounts a host directory (`/tmp/strimzi-data`) into the Kind node at `/var/lib/strimzi`.
  - This is typically used for persistent storage by the Strimzi Kafka operator running in the cluster.

---

## Why This File Is Important

- **Local Development**: Enables you to spin up a local Kubernetes cluster that closely resembles production, supporting realistic development and testing.
- **Port Forwarding**: Makes services running in the cluster accessible from your host machine via familiar ports.
- **Persistent Storage**: Ensures Kafka (via Strimzi) has a persistent data directory, even in a local environment.
- **Reproducibility**: Provides a consistent, version-controlled cluster setup for all developers.

---

For more details on Kind cluster configuration, see the [Kind documentation](https://kind.sigs.k8s.io/docs/user/configuration/). If you need further explanation of any section, refer to this document or ask for more information.
