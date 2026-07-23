data "google_dns_managed_zone" "default" {
  name = "subcloudlabs"
}

resource "google_compute_address" "external_load_balancer" {
  name         = "gke-external-load-balancer"
  region       = local.region
  network_tier = "STANDARD"
}

resource "google_dns_record_set" "bluejay" {
  name         = "bluejay.subcloudlabs.com."
  type         = "A"
  ttl          = 300
  managed_zone = data.google_dns_managed_zone.default.name
  rrdatas      = [google_compute_address.external_load_balancer.address]
}

resource "google_certificate_manager_dns_authorization" "bluejay" {
  name     = "bluejay-dns-auth"
  location = local.region
  domain   = "bluejay.subcloudlabs.com"
}

resource "google_dns_record_set" "bluejay_dns_auth" {
  name         = google_certificate_manager_dns_authorization.bluejay.dns_resource_record[0].name
  type         = google_certificate_manager_dns_authorization.bluejay.dns_resource_record[0].type
  ttl          = 300
  managed_zone = data.google_dns_managed_zone.default.name
  rrdatas      = [google_certificate_manager_dns_authorization.bluejay.dns_resource_record[0].data]
}

resource "google_certificate_manager_certificate" "bluejay" {
  name     = "bluejay-subcloudlabs-com"
  location = local.region
  managed {
    domains = ["bluejay.subcloudlabs.com"]
    dns_authorizations = [
      google_certificate_manager_dns_authorization.bluejay.id
    ]
  }
}