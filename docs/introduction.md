# Event-Driven Message System Guide

---

## Table of Contents

1. [System Overview](#system-overview)
2. [Key Technologies](#key-technologies)
   - [Kubernetes (K8s)](#kubernetes-k8s)
   - [Apache Kafka](#apache-kafka)
   - [PostgreSQL](#postgresql)
3. [Architecture Diagram](#architecture-diagram)
4. [Deployment Structure](#deployment-structure)
5. [High-Level Workflow](#high-level-workflow)
6. [Getting Started](#getting-started)
7. [Further Reading](#further-reading)

---

## System Overview

Our system is an **event-driven message platform** designed to handle asynchronous communication between services. It leverages Kubernetes for orchestration, Apache Kafka for messaging, and PostgreSQL for persistent storage. The system is containerized and can be deployed locally (via Docker) or on a Kubernetes cluster.

---

## Key Technologies

### Kubernetes (K8s)

- **What is it?** An open-source platform for automating deployment, scaling, and management of containerized applications.
- **Why do we use it?** It provides resilience, scalability, and easy management of our microservices and supporting infrastructure.

### Apache Kafka

- **What is it?** A distributed event streaming platform capable of handling high-throughput, fault-tolerant, real-time data feeds.
- **Why do we use it?** It enables decoupled communication between services through topics and message queues.

### PostgreSQL

- **What is it?** A powerful, open-source object-relational database system.
- **Why do we use it?** It stores persistent data for our services, such as user information, message logs, and system state.

---

## Architecture Diagram

```
[Frontend] <--> [Backend Service] <--> [Kafka Broker] <--> [PostgreSQL]
                                 |
                                 v
                        [Other Microservices]
```

- **Frontend**: User interface (web app) for interacting with the system.
- **Backend Service**: Handles business logic, API requests, and communicates with Kafka and Postgres.
- **Kafka Broker**: Manages message queues and topics for event-driven communication.
- **PostgreSQL**: Stores persistent data.
- **Other Microservices**: Additional services can subscribe/publish to Kafka topics.

---

## Deployment Structure

- **docker/**: Contains Docker Compose files for local development.
- **k8s/**: Kubernetes manifests for local or development cluster deployment.
- **k8s-prod/**: Kubernetes manifests for production deployment, including ingress and certificate management.
- **README.md**: High-level project overview and quickstart.
- **setup-cluster.sh / shutdown-cluster.sh**: Scripts to set up or tear down the local K8s cluster.

---

## High-Level Workflow

1. **User interacts with the Frontend** (web app).
2. **Frontend sends requests to the Backend Service** (API).
3. **Backend processes the request** and, if needed, publishes an event/message to a Kafka topic.
4. **Kafka Broker receives the message** and makes it available to any subscribed services.
5. **Other services or the Backend** consume the message, process it, and may update the PostgreSQL database.
6. **Frontend updates** based on new data or events.

---

## Getting Started

1. **Read the main [README.md](../README.md) for setup instructions.**
2. **Familiarize yourself with Docker and Kubernetes basics.**
   - [Kubernetes Official Docs](https://kubernetes.io/docs/home/)
   - [Docker Overview](https://docs.docker.com/get-started/overview/)
3. **Explore the k8s/ and k8s-prod/ directories** to see how deployments are defined.
4. **Ask questions!** The team is here to help you ramp up.

---

## Further Reading

- [Strimzi (Kafka on Kubernetes)](https://strimzi.io/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Event-Driven Architecture](https://martinfowler.com/articles/201701-event-driven.html)

---
