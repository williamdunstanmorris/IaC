module "gke" {
  source = "./modules/gcp-gke"
}

module "domains" {
  source = "./modules/gke-domains"
}

# 1. Bash history
# 2. State history
# 3. ARgocd runnning? Ok.
# 4. Push image to registry
# 4. Deploy simple one-piece app in the structure you have
# 5. Simulate some scenarios
