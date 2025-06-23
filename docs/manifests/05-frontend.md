# Frontend Kubernetes Manifest (`05-frontend.yaml`)

This manifest defines the Kubernetes resources required to deploy the frontend component of the event-driven message system. Below is an explanation of each section:

---

## 1. Service: `frontend`

- **Purpose:** Exposes the frontend application to external traffic via a NodePort service.
- **Kind:** `Service`
- **Type:** `NodePort`
- **Ports:**
  - Exposes port 3000 on the container
  - Maps to node port 30090 on the Kubernetes node
- **Selector:** Targets pods with the label `app: frontend`

---

## 2. Deployment: `frontend`

- **Purpose:** Runs the frontend web application (Next.js) for the event-driven message system.
- **Kind:** `Deployment`
- **Replicas:** 1
- **Image:** `conicle/dso-exam-01-frontend:v1.0.1`
- **Ports:**
  - Container exposes port 3000
- **Environment Variables:**
  - `NODE_ENV=production`
  - `NEXT_PUBLIC_INTERNAL_BACKEND_API_URI=http://backend:8080` (internal cluster communication)
  - `NEXT_PUBLIC_BACKEND_API_URI=http://localhost:8080` (external/local communication)
- **Resources:**
  - Requests: 256Mi memory, 100m CPU
  - Limits: 512Mi memory, 200m CPU
- **Probes:**
  - **Readiness:** HTTP GET `/` (initial delay: 15s, period: 30s)
  - **Liveness:** HTTP GET `/` (initial delay: 30s, period: 60s)

---

This manifest ensures the frontend application is accessible externally, properly configured for both internal and external backend API access, and monitored for health within the Kubernetes cluster.
