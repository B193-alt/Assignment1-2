# Self-Hosted Sentry on Google Cloud Platform

This project automates the deployment of a self-hosted Sentry instance on Google Cloud Platform (GCP) using Terraform and Ansible.

## Architecture
- **Infrastructure**: Terraform provisioning a GCP Compute Instance (`e2-standard-4`) and VPC/Firewall rules.
- **Configuration**: Ansible playbook installing Docker, Docker Compose, and running the Sentry installation script.

## Prerequisites
- Google Cloud Platform Account
- `gcloud` CLI installed and authenticated
- `terraform` >= 1.0
- `ansible` >= 2.10

## Directory Structure
```
.
├── terraform/          # Infrastructure as Code
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── provider.tf
├── ansible/            # Configuration Management
│   ├── inventory.ini
│   └── install_sentry.yml
└── README.md
```

## Quick Start

### 1. Provision Infrastructure
Navigate to the `terraform` directory and apply the configuration:
```bash
cd terraform
terraform init
terraform apply
```
*Note the `public_ip` output at the end.*

### 2. Configure & Install
Navigate to the `ansible` directory. Update `inventory.ini` with the public IP from the previous step.
```bash
cd ../ansible
# Ensure you have the SSH key generated during setup (gcp_key)
chmod 600 ../gcp_key
ansible-playbook -i inventory.ini install_sentry.yml
```

### 3. Access Sentry
Open your browser and navigate to:
`http://34.170.25.167:9000`

## Troubleshooting
- **Connection Refused**: Sentry takes 5-10 minutes to start up. If you see this, wait and retry.
- **SSH Timeout**: The instance might be under heavy load during the first boot. Wait a few minutes.
