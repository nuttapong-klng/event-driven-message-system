# Backend Kubernetes Manifest (`04-backend.yaml`)

This manifest defines the Kubernetes resources required to deploy the backend components of the event-driven message system. Below is an explanation of each section:

---

## 1. Job: `init-job`

- **Purpose:** Initializes the system by creating Kafka topics and initializing the database.
- **Kind:** `Job` (runs to completion)
- **Image:** `conicle/dso-exam-01-backend:v1.0.1`
- **Arguments:**
  - Runs the backend with the `init` command
  - Specifies Kafka brokers, topics, partitions, replication factor, and database connection
- **Environment Variables:**
  - `APP_ENV=production`
  - `LOG_LEVEL=info`
- **Resources:**
  - Requests: 128Mi memory, 100m CPU
  - Limits: 256Mi memory, 200m CPU
- **Restart Policy:** On failure

---

## 2. Service: `backend`

- **Purpose:** Exposes the backend deployment as a NodePort service for external access.
- **Kind:** `Service`
- **Type:** `NodePort`
- **Ports:**
  - Exposes port 8080 on the container
  - Maps to node port 30080
- **Selector:** Targets pods with the label `app: backend`

---

## 3. Deployment: `backend`

- **Purpose:** Runs the backend API server.
- **Kind:** `Deployment`
- **Replicas:** 1
- **Image:** `conicle/dso-exam-01-backend:v1.0.1`
- **Arguments:**
  - Runs the backend with the `serve` command
  - Specifies address, port, CORS, Kafka brokers, group ID, topics, and database connection
- **Environment Variables:**
  - `APP_ENV=production`
  - `LOG_LEVEL=info`
  - `LOG_FORMAT=json`
- **Resources:**
  - Requests: 256Mi memory, 100m CPU
  - Limits: 512Mi memory, 200m CPU
- **Probes:**
  - **Readiness:** HTTP GET `/health` (initial delay: 15s, period: 30s)
  - **Liveness:** HTTP GET `/health` (initial delay: 30s, period: 60s)

---

## 4. Deployment: `consumer`

- **Purpose:** Runs a consumer service that processes messages from Kafka.
- **Kind:** `Deployment`
- **Replicas:** 1
- **Image:** `conicle/dso-exam-01-backend:v1.0.1`
- **Arguments:**
  - Runs the backend with the `consume` command
  - Specifies Kafka brokers, topics, group ID, and database connection
- **Environment Variables:**
  - `APP_ENV=production`
  - `LOG_LEVEL=info`
  - `LOG_FORMAT=json`
- **Resources:**
  - Requests: 256Mi memory, 100m CPU
  - Limits: 512Mi memory, 200m CPU
- **Liveness Probe:**
  - Uses an exec command to check if the consume process is running (`ps aux | grep '[c]onsume'`)
  - Initial delay: 30s, period: 60s

---

This manifest ensures the backend and consumer components are properly initialized, exposed, and monitored within the Kubernetes cluster.
