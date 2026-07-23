resource "helm_release" "argo_cd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "9.5.15"
  create_namespace = true
  namespace = "argocd"
  set = [
    {
      name  = "server.service.type"
      value = "LoadBalancer"
    }
  ]
}

resource "helm_release" "grafana" {
  name             = "grafana"
  repository       = "https://grafana-community.github.io/helm-charts"
  chart            = "grafana"
  version          = "12.7.2"
  create_namespace = true
  namespace        = "monitoring"
}