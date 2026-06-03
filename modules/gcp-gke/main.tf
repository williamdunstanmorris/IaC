locals {
  oauth_scopes = [
    "https://www.googleapis.com/auth/cloud-platform",
    "https://www.googleapis.com/auth/devstorage.read_only",
    "https://www.googleapis.com/auth/logging.write",
    "https://www.googleapis.com/auth/monitoring",
    "https://www.googleapis.com/auth/service.management.readonly",
    "https://www.googleapis.com/auth/servicecontrol",
    "https://www.googleapis.com/auth/trace.append",
    "https://www.googleapis.com/auth/cloud-platform"
  ]
  region = "europe-west3"
  zone = "europe-west3-b"
}

resource "google_compute_router" "router" {
  name    = "vpc-router"
  region  = "europe-west3" # Ensure this matches your subnet region!
  network = google_compute_network.vpc.id
}

# 2. Configure Cloud NAT for the VPC
resource "google_compute_router_nat" "nat" {
  name                               = "vpc-nat"
  router                             = google_compute_router.router.name
  region                             = google_compute_router.router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  # subnetwork {
  #   name = google_compute_subnetwork.public.id
  #   source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  # }

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

resource "google_compute_subnetwork" "public" {
  name          = "public-gke"
  network       = google_compute_network.vpc.name
  region        = local.region
  ip_cidr_range = cidrsubnet("10.0.0.0/22", 1, 0)
}

resource "google_compute_subnetwork" "private" {
  name          = "private-gke"
  network       = google_compute_network.vpc.name
  region        = local.region
  ip_cidr_range = cidrsubnet("10.0.0.0/22", 1, 1)
}

resource "google_compute_network" "vpc" {
  name                    = "main"
  auto_create_subnetworks = false
}

resource "google_container_cluster" "default" {
  name                     = "app-cluster"
  deletion_protection      = false
  location                 = local.zone
  initial_node_count       = 1
  remove_default_node_pool = true
  network                  = google_compute_network.vpc.name
  subnetwork               = google_compute_subnetwork.private.name

  gateway_api_config {
    # Instructs GKE to install the CRDs of the Gateway API Standard Channel with the cluster
    channel = "CHANNEL_STANDARD"
  }

  addons_config {
    http_load_balancing {
      disabled = false
    }
    horizontal_pod_autoscaling {
      disabled = false
    }
  }

  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = google_compute_subnetwork.public.ip_cidr_range
      display_name = "Public Subnet"
    }
    cidr_blocks {
      cidr_block = "94.139.28.73/32"
      display_name = "Will Mac"
    }
  }
}

resource "google_container_node_pool" "system" {
  name               = "system"
  location = local.zone
  cluster            = google_container_cluster.default.name
  initial_node_count = 1

  management {
    auto_repair = true
  }

  node_config {
    service_account = google_service_account.primary.email
    machine_type    = "e2-medium"
    disk_type       = "pd-standard"
    oauth_scopes    = local.oauth_scopes

    labels = {
      node-role = "system"
    }

    taint {
      key    = "node-role"
      value  = "system"
      effect = "NO_SCHEDULE"
    }
  }
}

resource "google_container_node_pool" "workload" {
  name               = "workload"
  location           = local.zone
  cluster            = google_container_cluster.default.name
  initial_node_count = 1

  autoscaling {
    min_node_count = 1
    max_node_count = 5
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  node_config {
    service_account = google_service_account.primary.email
    machine_type    = "e2-medium"
    disk_type       = "pd-standard"
    spot            = true

    labels = {
      node-role = "workload"
    }

    oauth_scopes = local.oauth_scopes
  }
}

resource "google_service_account" "primary" {
  account_id   = "gke-node-sa"
  display_name = "GKE Service Account"
}

resource "google_project_iam_member" "gke_sa_editor" {
  project = data.google_project.project.id
  role    = "roles/editor"
  member  = "serviceAccount:${google_service_account.primary.email}"
}

resource "google_artifact_registry_repository" "default" {
  repository_id = "main"
  format        = "DOCKER"
  vulnerability_scanning_config {
    enablement_config = "INHERITED"
  }
  docker_config {
    immutable_tags = true
  }
}
