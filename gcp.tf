module "gke" {
  source = "./modules/gcp-gke"
}

module "domains" {
  source = "./modules/gke-domains"
}