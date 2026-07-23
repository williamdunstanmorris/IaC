terraform {
  required_providers {
    argocd = {
      source = "argoproj-labs/argocd"
    }
  }
}

resource "argocd_application" "cluster_infra" {
  metadata {
    name      = "cluster-infra"
    namespace = "argocd"
  }

  spec {
    destination {
      server    = "https://kubernetes.default.svc"
      namespace = "argocd"
    }
    revision_history_limit = 10

    source {
      repo_url        = "https://github.com/williamdunstanmorris/IaC"
      target_revision = "HEAD"
      path            = "K8/cluster-infra"
    }

    sync_policy {
      automated {
        allow_empty = false
        prune = true
        self_heal = true
      }
    }
  }
}
