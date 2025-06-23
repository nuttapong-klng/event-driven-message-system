# PostgreSQL Deployment Manifest (k8s/03-postgres.yaml)

This manifest provisions a PostgreSQL database instance for the `event-driven-message-system` namespace in Kubernetes. It is composed of several resources that together ensure secure, persistent, and configurable database operation.

## Components

### 1. Secret

- **Purpose:** Stores sensitive information (username, password, database name) in base64-encoded form.
- **Resource:** `Secret` named `postgres-secret`.
- **Keys:**
  - `POSTGRES_USER`: Database username
  - `POSTGRES_PASSWORD`: Database password
  - `POSTGRES_DB`: Default database name

### 2. ConfigMap

- **Purpose:** Supplies custom PostgreSQL configuration settings for performance and resource tuning.
- **Resource:** `ConfigMap` named `postgres-config`.
- **Key:** `postgresql.conf` (contains configuration parameters)

### 3. Service

- **Purpose:** Exposes PostgreSQL on port 5432 within the cluster, enabling other services to connect.
- **Resource:** `Service` named `postgres`.
- **Selector:** Matches pods with label `app: postgres`.

### 4. StatefulSet

- **Purpose:** Manages the lifecycle of the PostgreSQL pod, ensuring stable network identity and persistent storage.
- **Resource:** `StatefulSet` named `postgres`.
- **Key Features:**
  - **Replicas:** 1 (single instance)
  - **Persistent Storage:** Uses a `PersistentVolumeClaim` for data durability.
  - **Config Mounts:**
    - Mounts the custom `postgresql.conf` from the ConfigMap.
    - Mounts the data directory for persistence.
  - **Resource Requests/Limits:** Sets CPU and memory requests/limits for the container.
  - **Health Checks:**
    - **Liveness Probe:** Uses `pg_isready` to check if the database is alive.
    - **Readiness Probe:** Uses `pg_isready` to check if the database is ready to accept connections.

## Summary

This manifest ensures that a secure, persistent, and configurable PostgreSQL instance is available for the event-driven-message-system application, following best practices for Kubernetes deployments.
