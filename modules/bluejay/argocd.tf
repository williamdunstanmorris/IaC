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
        # Allow empty stops accidental deletion in git, leading to resource pruning (& outage!)
        allow_empty = false
        # Use pruning: prevent operational drift, waste, & enhance security (RBAC).
        # Do not use pruning: Stateful resources  (e.g. persistent volume claims,
        # shared cluster resources), Disaster recovery & debugging
        prune       = true
        # Self heal: When another client is interacting e.g. kubectl.
        # Turn off during an outage, if an engineer needs to recover or scale up quickly.
        self_heal   = true
      }
    }
  }
}

resource "argocd_application" "cluster_apps" {
  metadata {
    name      = "cluster-apps"
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
      path            = "K8/cluster-apps"
    }

    sync_policy {

      automated {
        # Allow empty stops accidental deletion in git, leading to resource pruning (& outage!)
        allow_empty = false
        # Use pruning: prevent operational drift, waste, & enhance security (RBAC).
        # Do not use pruning: Stateful resources  (e.g. persistent volume claims,
        # shared cluster resources), Disaster recovery & debugging
        prune       = true
        # Self heal: When another client is interacting e.g. kubectl.
        # Turn off during an outage, if an engineer needs to recover or scale up quickly.
        self_heal   = true
      }
    }
  }
}