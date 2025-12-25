## Overview

This project provides a full infrastructure and deployment setup for the RealWorld backend service, including:

- Infrastructure as Code (Terraform)
- Kubernetes orchestration (EKS)
- CI/CD via GitHub Actions
- Secure secrets management
- Centralized logging and monitoring
- AWS-native ingress via ALB

The goal is a **reproducible, auditable, scalable** backend platform.

---

## High-Level Architecture

![Architecture diagram](docs/architecture.png)

---

## ☁ Infrastructure (Terraform)

All infrastructure is provisioned using **Terraform**.

### Provisioned resources
- VPC with public/private subnets
- EKS cluster with managed node groups
- ECR repository for backend images
- EC2 instance for monitoring stack
- IAM roles and policies
- S3 backend for Terraform state

### Usage

```bash
terraform init
terraform apply
```

## Kubernetes

### Namespaces
**realworld**   -   Application workloads
**kube-system** -	Core EKS components
**monitoring**  -  	Metrics exporters
**logging**     - 	Log collection

## Ingress & Networking
Ingress is handled by AWS Load Balancer Controller.

### Characteristics:
- Internet-facing ALB
- Host-based routing
- Kubernetes-native ingress resources
- Example endpoint:

http://realworld-inc.link

## Docker & Application Build
The backend is built as a Docker image and pushed to Amazon ECR.
### Key points:
- Prisma client is generated during image build
- .env is not baked into the image
- Secrets are injected at runtime
- Production Node.js image is used

## Configuration & Secrets
### Required environment variables
Variable	Description
**DATABASE_URL**    -	PostgreSQL connection string
**JWT_SECRET**      -	Secret for JWT signing
**NODE_ENV**        -  	production
Secrets handling
Stored in GitHub Actions Secrets for CI/CD
Stored as Kubernetes Secrets for runtime
Never committed to the repository

## CI/CD Pipeline
CI/CD is implemented using GitHub Actions.
It is located in **realworld-example-app/.github/workflows/build-and-deploy.yml**
Helm configs are located in **realworld-example-app/helm**
### Pipeline steps
- Checkout repository
- Install dependencies
- Build application
- Build Docker image
- Push image to ECR
- Deploy to EKS using Helm

## Monitoring
Monitoring stack runs on a dedicated EC2 instance.
Dashboards with logs and monitorigns are available here - http://52.20.129.88:3000/dashboards, but the access to it limited on a security groups level.
### Components
**Prometheus** – metrics collection
**Grafana** – dashboards & visualization
**node-exporter** – node metrics
**kube-state-metrics** – cluster state

### Why external monitoring?
- No load on EKS control plane
- Independent lifecycle
- Survives cluster recreation
- Clear separation of concerns

## Logging
Centralized logging using Loki + Promtail.

### Log flow
```
Kubernetes Pods
   ↓
Promtail (DaemonSet)
   ↓
Loki
   ↓
Grafana
```

Logs can be filtered by:
- namespace
- pod
- container
- labels

## Backups

### Database
- Daily automated backups
- Retention policy configurable
- Supports point-in-time recovery
- Terraform state
- Stored in S3
- Versioning enabled

## 📝 Notes & Trade-offs

- **Terraform structure**  
  Ideally, the Terraform codebase should be fully modularized (VPC, EKS, networking, IAM, monitoring, etc. as separate reusable modules).  
  In this project, I initially started with a flat structure, and refactoring it into clean modules later would have required non-trivial effort. Given the scope and time constraints of the assignment, I decided not to refactor it further.  
  In a real production environment, I would absolutely split the infrastructure into well-defined Terraform modules.

- **Ansible runner setup**  
  The Ansible playbooks used to provision the self-hosted GitHub Actions runner are intentionally minimal and incomplete.  
  I planned to improve them (better idempotency, roles, variables, hardening), but did not do so due to time limitations.  
  The goal here was to demonstrate the overall approach rather than produce a fully polished Ansible codebase.

- **Database migrations**  
  Database migrations were not applied. As a result, the `/api/tags` endpoint returns an error.  
  This was a conscious decision: the primary goal of the assignment was to design and deploy infrastructure, not to debug or extend the application logic itself.  
  Importantly, this error confirms that the application successfully connects to the database and executes queries.

- **Monitoring depth**  
  Grafana dashboards used in this setup are pre-built community dashboards that expose only basic signals (CPU, memory, pod status, etc.).  
  The objective was not to design a comprehensive observability strategy with custom HTTP metrics and SLOs, but to demonstrate the ability to:
  - export metrics
  - collect them centrally
  - store historical data
  - visualize and debug system behavior  
  Creating custom application-level metrics was intentionally out of scope for this task.
