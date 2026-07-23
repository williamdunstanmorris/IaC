locals {
  vpc_supernet = "10.0.0.0/8"

  nodes_cidr      = cidrsubnet(local.vpc_supernet, 8, 0)
  pods_cidr       = cidrsubnet(local.vpc_supernet, 8, 1)
  services_cidr   = cidrsubnet(local.vpc_supernet, 8, 2)
  proxy_only_cidr = cidrsubnet(local.vpc_supernet, 8, 3)
}

resource "google_compute_network" "vpc" {
  name                    = "main"
  auto_create_subnetworks = false
}

resource "google_compute_router" "router" {
  name    = "vpc-router"
  region  = "europe-west3"
  network = google_compute_network.vpc.id
}

resource "google_compute_router_nat" "nat" {
  name                               = "vpc-nat"
  router                             = google_compute_router.router.name
  region                             = google_compute_router.router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

resource "google_compute_subnetwork" "private" {
  name    = "private-gke"
  network = google_compute_network.vpc.name
  region  = local.region
  # 10.0.0.0/20 — plenty for node IPs
  ip_cidr_range = cidrsubnet(local.nodes_cidr, 4, 0)

  private_ip_google_access = true

  secondary_ip_range {
    range_name = "pods"
    # 10.1.0.0/16 — ~65k pod IPs
    ip_cidr_range = local.pods_cidr
  }

  secondary_ip_range {
    range_name = "services"
    # 10.2.0.0/20 — 4096 service IPs
    ip_cidr_range = cidrsubnet(local.services_cidr, 4, 0)
  }
}

resource "google_compute_subnetwork" "proxy_only" {
  name    = "private-proxy-only-gke"
  network = google_compute_network.vpc.name
  region  = local.region
  # 10.2.0.0/20 — 4096 service IPs
  ip_cidr_range = cidrsubnet(local.proxy_only_cidr, 7, 0)
  purpose       = "REGIONAL_MANAGED_PROXY"
  role          = "ACTIVE"
}