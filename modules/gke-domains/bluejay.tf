resource "google_dns_record_set" "bluejay" {
  name         = "bluejay.subcloudlabs.com."
  type         = "A"
  ttl          = 300
  managed_zone = google_dns_managed_zone.default.name
  rrdatas      = [google_compute_global_address.ingress.address]
}

resource "google_certificate_manager_certificate" "bluejay" {
  name = "bluejay-subcloudlabs-com"
  managed {
    domains = ["bluejay.subcloudlabs.com"]
  }
}

resource "google_certificate_manager_certificate_map" "bluejay" {
  name = "bluejay-cert-map"
}

resource "google_certificate_manager_certificate_map_entry" "bluejay" {
  name         = "bluejay-map-entry"
  map          = google_certificate_manager_certificate_map.bluejay.name
  hostname     = "bluejay.subcloudlabs.com"
  certificates = [google_certificate_manager_certificate.bluejay.id]
}
