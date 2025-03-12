# 🎮 DevOps OpenDAoC Infrastructure

This repository contains the Terraform infrastructure-as-code for deploying a complete Kubernetes-based gaming platform on AWS. The platform uses EKS (Elastic Kubernetes Service) and provides a comprehensive set of DevOps tools for continuous delivery, monitoring, and backup.

## 🏗️ Architecture Overview

The infrastructure consists of the following major components:

1. **🌐 AWS Networking**: VPC with public and private subnets across multiple availability zones
2. **☸️ EKS Cluster**: Managed Kubernetes with autoscaling node groups
3. **🚢 GitOps with ArgoCD**: Continuous delivery of Kubernetes applications
4. **📊 Monitoring Stack**: Prometheus and Grafana for observability
5. **🔌 Ingress Controller**: NGINX for exposing services
6. **🔒 Certificate Management**: Automatic TLS certificate provisioning
7. **💾 Backup Solution**: Velero for Kubernetes backup and restore capabilities

## 🧩 Infrastructure Components

### 🌐 Networking (modules/networking)

- Creates a VPC with public and private subnets across multiple availability zones
- Provisions NAT gateways for private subnet connectivity
- Sets up security groups for public and private resources
- Adds proper tagging for Kubernetes load balancer integration

### ☸️ EKS Cluster (modules/eks)

- Deploys an EKS cluster with managed node groups
- Configures AWS EBS CSI driver for persistent storage
- Sets up IAM roles for service accounts (IRSA)
- Creates a default `gp3` storage class
- Configures AWS Auth mapping for cluster access

### 🔒 Certificate Manager (modules/cert-manager)

- Deploys cert-manager for automatic TLS certificate management
- Configures Let's Encrypt as the certificate issuer
- Supports automatic certificate renewal

### 🔌 Ingress Controller (modules/ingress)

- Deploys NGINX Ingress Controller as a DaemonSet
- Configures an Network Load Balancer for incoming traffic
- Supports TCP services for game server connectivity

### 📊 Monitoring Stack (modules/monitoring)

- Deploys Prometheus for metrics collection
- Configures Grafana for dashboards and visualization
- Sets up AlertManager with Slack integration
- Provisions ingress for web access to Grafana

### 🚢 ArgoCD (modules/argocd)

- Deploys ArgoCD for GitOps-based application deployment
- Configures application projects and repositories
- Sets up synchronization for database and core applications
- Provisions ingress for web access to ArgoCD UI

### 💾 Backup Solution (modules/velero)

- Deploys Velero for Kubernetes backup and disaster recovery
- Creates S3 bucket for backup storage
- Configures scheduled backups with retention policies
- Sets up IAM roles for S3 and EBS snapshot access

### 📦 State Management

- Configures S3 backend for Terraform state storage
- Uses DynamoDB for state locking
- Provides better reliability for the infrastructure initialization

## 🎲 Deployed Applications

### 🎲 OpenDAoC Core Game Server

- **Repository**: GitHub-hosted container image
- **Architecture**: Stateless deployment with 2 replicas
- **Configuration**: 
  - Runs on port 10300 with TCP ingress
  - Connects to database via secure connection string
  - Customisable environment variables via the configmap

### 🗄️ OpenDAoC Database 

- **Ready to use**: OpenDAoC Database Dump bootstraped into a MariaDB docker image
- **Database**: MariaDB-based stateful set with 3 replicas
- **Storage**: Persistent volumes using EBS gp3 storage class to enable the snapshot capability
- **TO-DO**:
  - MariaDB replication to the secondary Statefulset pods for a full HA DB

### 🔄 GitOps Workflow

ArgoCD manages both database and game server applications:
- Application definitions stored in Git (version controlled)
- Automatic synchronization from Git to cluster
- Sequential deployment (database before game server)
- Secrets injected at runtime from Terraform variables

## 🔐 Security Best Practices

The following security best practices are implemented:

1. **🧱 Network Segmentation**:
   - Workloads run in private subnets
   - Public subnets only used for load balancers
   - Security groups limit traffic between components

2. **🛡️ Least Privilege IAM**:
   - Service-specific IAM roles with minimal permissions
   - IAM roles for service accounts to avoid instance profiles
   - No use of AWS access keys in pods

3. **🔑 Secret Management**:
   - Sensitive variables marked with `sensitive = true`
   - Secrets templating for GitOps workflows
   - Avoidance of hardcoded credentials
   - Base64 encoding for sensitive configuration values

4. **🔐 TLS Everywhere**:
   - Automatic TLS certificate provisioning
   - SSL passthrough for sensitive services
   - Force SSL redirection

5. **⚔️ Kubernetes Security**:
   - Private API endpoint with controlled access
   - AWS Auth configmap for IAM-based access control
   - Default EBS volume encryption

## ⚙️ Operational Features

1. **🔄 Backup and Disaster Recovery**:
   - Automated daily backups with Velero
   - 30-day backup retention policy
   - Volume snapshots for stateful workloads

2. **📡 Monitoring and Alerting**:
   - Comprehensive metrics collection with Prometheus
   - Visual dashboards with Grafana
   - Slack notifications for critical alerts

3. **🚀 Continuous Delivery**:
   - GitOps workflow with ArgoCD
   - Application configuration as code
   - Automated synchronization with git repositories

4. **📝 Infrastructure as Code**:
   - Complete infrastructure defined in Terraform
   - Modular design for reusability
   - Version controlled infrastructure changes

## 🔄 GitHub Actions Workflows

The repository includes the following CI/CD workflows:

1. **🚀 Deploy Infrastructure** (deploy-infra.yaml):
   - Security scanning with tfsec and checkov
   - Terraform state initialization
   - Infrastructure deployment

2. **🧹 Destroy Infrastructure** (destroy-infra.yaml):
   - Safe destruction with confirmation checks
   - Cleanup of Kubernetes resources
   - State infrastructure cleanup

3. **🔄 DNS Management** (update-dns-records.yaml):
   - Updates DNS records for all services
   - Points to the Load Balancer endpoint
   - Supports manual and automated execution

## 📋 Prerequisites

- AWS Account with appropriate permissions
- Domain name for services (Grafana, ArgoCD, Game Server)
- GitHub repository for application code
- Terraform 1.5.7 or later
- AWS CLI configured with appropriate credentials

## 🚀 Deployment Instructions

### 1. Initial Setup

Clone the repository and navigate to the terraform directory:

```bash
git clone https://github.com/gz-42/devops-opendaoc.git
cd terraform
```

### 2. Configure Backend State

Initialize the S3 backend for state storage:

```bash
cd tfstate-init
terraform init
terraform apply
```

Note the output values for bucket name and DynamoDB table.

### 3. Configure Variables

Create a secret file with your configuration values or set them as GitHub repository secrets for CI/CD.

You can also put your own values in the main terraform variables.yaml file. If you do so, i recommend to do it in a private repo or localy to not expose sensitive informations.

If you want to deploy it on a local cluster you can use the manifests in the repo or adapt the helm charts to your needs.

### 4. Deploy Infrastructure

Either deploy using the GitHub Actions workflow or manually:

```bash
terraform init \
  -backend-config="bucket=YOUR_STATE_BUCKET" \
  -backend-config="key=terraform.tfstate" \
  -backend-config="region=YOUR_REGION" \
  -backend-config="dynamodb_table=YOUR_DYNAMODB_TABLE"

terraform plan -out=tfplan
terraform apply tfplan
```

### 5. Access Services

After deployment, you can access the services at:

- ArgoCD: https://argocd.yourdomain.com
- Grafana: https://grafana.yourdomain.com
- Game Server: your-game-server.yourdomain.com (port 10300)

To access the gameserver, you will need to download the OpenDAoC Client and follow the instructions on the official website
```bash
https://www.opendaoc.com/docs/client/
```
## ✅ Best Practices Implemented

1. **📦 Modular Structure**:
   - Each component is a separate Terraform module
   - Clear inputs and outputs for modules
   - Reusable infrastructure components

2. **🏷️ Resource Tagging**:
   - Consistent tagging strategy
   - Environment, project, and terraform-managed tags
   - Proper Kubernetes tags for auto-discovery

3. **📌 Version Pinning**:
   - Terraform providers have version constraints
   - Helm charts use specific versions
   - AWS module versions are pinned

4. **✅ Variable Validation**:
   - Variables have descriptions
   - Sensitive data is marked
   - Default values where appropriate

5. **📦 State Management**:
   - Remote state with locking
   - State separation for critical components
   - CI/CD integration

6. **🛠️ Error Handling**:
   - Graceful destruction hooks
   - Dependencies clearly defined
   - Timeout configurations for long-running operations

7. **🔑 Secret Management**:
   - Template-based secret injection
   - No plain text secrets in code
   - Secret rotation support

8. **🔄 High Availability**:
   - Multi-AZ deployment
   - Redundant NAT gateways
   - Autoscaling node groups
   - Database replication with 3-node MariaDB cluster

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run security scans
5. Submit a pull request

## 📄 License

DevOps-OpenDAoC and OpenDAoC are licensed under the GNU General Public License (GPL) v3 to serve the DAoC community and promote open-source development.
See the LICENSE file for more details.
