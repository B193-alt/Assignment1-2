terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

resource "google_compute_network" "vpc_network" {
  name = "sentry-network"
}

resource "google_compute_firewall" "allow_ssh_http_sentry" {
  name    = "allow-ssh-http-sentry"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443", "9000"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["sentry-server"]
}

resource "google_compute_instance" "vm_instance" {
  name         = "sentry-vm"
  machine_type = var.machine_type
  tags         = ["sentry-server"]
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 50
    }
  }

  network_interface {
    network = google_compute_network.vpc_network.name
    access_config {
      // Ephemeral public IP
    }
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${file(var.ssh_pub_key_path)}"
  }
}
