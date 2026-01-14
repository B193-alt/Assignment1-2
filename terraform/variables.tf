variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "GCP Zone"
  type        = string
  default     = "us-central1-a"
}

variable "machine_type" {
  description = "GCP Machine Type"
  type        = string
  default     = "e2-standard-8" # 8 vCPU, 32GB Memory (Required for Sentry Startup)
}

variable "ssh_user" {
  description = "SSH User for Ansible"
  type        = string
  default     = "ubuntu"
}

variable "ssh_pub_key_path" {
  description = "Path to public SSH key"
  type        = string
  default     = "../gcp_key.pub"
}
