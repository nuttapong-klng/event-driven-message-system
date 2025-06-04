# Production Kubernetes Setup

This directory contains the production-grade Kubernetes configurations using Strimzi Kafka Operator and Kind cluster.

## Prerequisites

- Docker Desktop installed and running
- Kind (Kubernetes in Docker) installed
- kubectl installed and configured
- Helm v3 installed

## Installation Steps

1. Run setup script
```bash
sh ./setup-cluster.sh
```

## Accessing the Application

The application is accessible through:
- Frontend: http://localhost:3000
- API endpoints: http://localhost/8080


## Cleanup

To remove all resources:
```bash
sh ./shutdown-cluster.sh
``` 