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
`http://34.31.185.107:9000`

## Assignment 2: Scripting & Automation (Log Rotation)

A shell script located in `automation/rotate_logs.sh` handles the rotation, compression, and retention of the application log file.

### How the Script Works:
1.  **Isolation**: It uses a `copytruncate` strategy. It copies the active log file to the archive directory and then empties (truncates) the original. This allows the application to keep its file handle open without interruption.
2.  **Compression**: Immediately after rotation, the archive is compressed using `gzip` to save disk space.
3.  **Retention**: It uses the `find` command to locate and delete files in the archive directory that are older than 5 days.
4.  **Error Handling**:
    *   Checks for `root` permissions.
    *   Exits gracefully if the log file is missing.
    *   Creates required directories if they don't exist (idempotency).

### Cron Schedule:
To run this daily at midnight, add the following to your root crontab (`sudo crontab -e`):
```cron
0 0 * * * /path/to/automation/rotate_logs.sh >> /var/log/log_rotation.log 2>&1
```

### How to Test Manually:
1.  Create a dummy log file: `sudo touch /var/log/application.log`
2.  Add some data: `echo "test logs" | sudo tee -a /var/log/application.log`
3.  Execute the script: `sudo ./automation/rotate_logs.sh`
4.  Verify the archive: `ls /var/log/archive`
