
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