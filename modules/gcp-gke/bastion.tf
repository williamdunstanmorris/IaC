resource "google_compute_firewall" "allow_iap_ssh" {
  name    = "allow-iap-ssh-to-bastion"
  network = google_compute_network.vpc.id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  # Your IAP firewall rule allows traffic from 0.0.0.0/0. Google Cloud's IAP TCP forwarding service always uses a specific, fixed IP block to connect to your instances. If you don't use this exact CIDR block, IAP connections will drop.
  source_ranges = ["35.235.240.0/20"]
  target_tags   = ["iap-bastion"]
}

resource "google_service_account" "bastion" {
  account_id   = "gke-bastion"
  display_name = "Service Account for GKE Bastion VM"
}

resource "google_compute_instance" "bastion" {
  name         = "gke-bastion-host"
  machine_type = "e2-micro"
  tags         = ["iap-bastion"]
  zone         = local.zone

  network_interface {
    network    = google_compute_network.vpc.name
    subnetwork = google_compute_subnetwork.public.name
  }

  service_account {
    email  = google_service_account.bastion.email
    scopes = ["cloud-platform"]
  }

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2404-lts-amd64"
      size  = 20
    }
  }

  metadata_startup_script = <<-EOT
    #!/bin/bash
    set -e

    # Update package lists
    apt-get update -y
    apt-get install -y apt-transport-https ca-certificates curl gnupg

    # Create keyring directory safely
    install -m 0755 -d /etc/apt/keyrings

    # Add Google Cloud public signing key (with --yes to overwrite smoothly if needed)
    curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --yes --dearmor -o /etc/apt/keyrings/kubernetes-archive-keyring.gpg

    # Add official Google Cloud CLI and GKE auth repositories
    echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee /etc/apt/sources.list.d/google-cloud-sdk.list

    # Re-update and install the required tools
    apt-get update -y
    apt-get install -y google-cloud-cli google-cloud-cli-gke-gcloud-auth-plugin kubectl
  EOT
}

# 4. Grant Users Permission to Tunnel via IAP
resource "google_project_iam_member" "iap_tunnel_user" {
  project = data.google_project.project.id
  role    = "roles/iap.tunnelResourceAccessor"
  member  = "user:itswillmo@pm.me"
}

# 5. Grant Users Permission to SSH into Compute Instances
resource "google_project_iam_member" "compute_ssh_user" {
  project = data.google_project.project.id
  role    = "roles/compute.viewer"
  member  = "user:itswillmo@pm.me"
}

resource "google_project_iam_member" "bastion_gke_viewer" {
  project = "project-2b40a90c-1a89-477e-894"
  role    = "roles/container.viewer"
  member  = "serviceAccount:${google_service_account.bastion.email}"
}