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
  zone   = "europe-west3-b"
}

resource "google_container_cluster" "default" {
  name                     = "app-cluster"
  location                 = local.zone
  deletion_protection      = false
  initial_node_count       = 1
  remove_default_node_pool = true

  network    = google_compute_network.vpc.name
  subnetwork = google_compute_subnetwork.private.name

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

  ip_allocation_policy {
    cluster_secondary_range_name  = "pods"
    services_secondary_range_name = "services"
  }

  # If you want this cluster kubectl, helm to be accessible only from IPs, add this.
  # master_authorized_networks_config {
  # cidr_blocks {
  #   cidr_block   = google_compute_subnetwork.public.ip_cidr_range
  #   display_name = "Public Subnet"
  # }
  # cidr_blocks {
  #   cidr_block = "94.139.28.73/32"
  #   display_name = "Will Mac"
  # }
  # }
}

# resource "google_container_node_pool" "system" {
#   name               = "system"
#   location = local.zone
#   cluster            = google_container_cluster.default.name
#   initial_node_count = 1
#
#   management {
#     auto_repair = true
#   }
#
#   node_config {
#     service_account = google_service_account.primary.email
#     machine_type    = "e2-medium"
#     disk_type       = "pd-standard"
#     oauth_scopes    = local.oauth_scopes
#
#     labels = {
#       node-role = "system"
#     }
#
#     taint {
#       key    = "node-role"
#       value  = "system"
#       effect = "NO_SCHEDULE"
#     }
#   }
# }

# Create node pool categorised on cpu, memory
# Create node pool categorised on k8 versions
resource "google_container_node_pool" "workload" {
  name               = "workload"
  location           = local.zone
  cluster            = google_container_cluster.default.name
  initial_node_count = 2


  autoscaling {
    min_node_count = 1
    max_node_count = 5
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  # upgrade_settings {
  # strategy = "SURGE"
  # Higher when you want to ensure faster
  # upgrade times for old nodes draining
  # max_surge = 2
  # blue_green_settings {
  # standard_rollout_policy {
  #   batch_node_count = 1
  #   batch_percentage = 100
  #   batch_soak_duration = "10"
  # }
  # node_pool_soak_duration = ""
  # }
  # }

  node_config {
    service_account = google_service_account.primary.email
    machine_type    = "e2-medium"
    disk_type       = "pd-standard"

    # spot            = true

    labels = {
      node-role = "workload"
    }

    # taint {
    #   key    = "node-role"
    #   value  = "system"
    #   effect = "NO_SCHEDULE"
    # }

    oauth_scopes = local.oauth_scopes
  }
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
