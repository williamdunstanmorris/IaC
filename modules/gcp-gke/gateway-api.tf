# Create a regional static IP address for the external load balancer.

resource "google_compute_address" "external_load_balancer" {
  name         = "gke-external-load-balancer"
  region       = local.region
  network_tier = "STANDARD"
}