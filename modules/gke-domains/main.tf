resource "google_dns_managed_zone" "default" {
  name        = "subcloudlabs"
  dns_name    = "subcloudlabs.com."
  description = "Subcloud Labs primary DNS zone"
}

resource "google_compute_global_address" "ingress" {
  name = "gke-ingress-ip"
}

resource "google_compute_managed_ssl_certificate" "argocd" {
  name = "gke-managed-cert"
  managed {
    domains = [
      "argocd.subcloudlabs.com"
    ]
  }
}

resource "google_dns_record_set" "argocd" {
  name         = "argocd.subcloudlabs.com."
  type         = "A"
  ttl          = 300
  managed_zone = google_dns_managed_zone.default.name
  rrdatas      = [google_compute_global_address.ingress.address]
}

# resource "google_dns_record_set" "grafana" {
#   name         = "grafana.subcloudlabs.com."
#   type         = "A"
#   ttl          = 300
#   managed_zone = google_dns_managed_zone.default.name
#   rrdatas      = [google_compute_global_address.ingress.address]
# }
#
# resource "google_dns_record_set" "app" {
#   name         = "app.subcloudlabs.com."
#   type         = "A"
#   ttl          = 300
#   managed_zone = google_dns_managed_zone.default.name
#   rrdatas      = [google_compute_global_address.ingress.address]
# }

output "nameservers" {
  value = google_dns_managed_zone.default.name_servers
}