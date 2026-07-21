#!/bin/bash
# TODO: Add to the charts instead. As declarative HELM.
helm repo add grafana-community https://grafana-community.github.io/helm-charts

helm repo list && helm repo update

kubectl create namespace monitoring

helm search repo grafana-community/grafana

helm install my-grafana grafana-community/grafana --create-namespace --namespace monitoring

helm list -n monitoring

kubectl get all -n monitoring

helm get notes my-grafana -n monitoring

kubectl get secret --namespace monitoring my-grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo

export POD_NAME=$(kubectl get pods --namespace monitoring -l "app.kubernetes.io/name=grafana,app.kubernetes.io/instance=my-grafana" -o jsonpath="{.items[0].metadata.name}")

kubectl --namespace monitoring port-forward $POD_NAME 3000

##  Default namespace for kubectl config must be set to argocd. This is only needed for the following commands since the previous commands have -n argocd already:
#kubectl config set-context --current --namespace=grafana
#
## Change the argocd-server service type to LoadBalancer
#kubectl patch svc argo-argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
#
## You can retrieve this IP with
#kubectl get svc argo-argocd-server -n argocd
#
## Port Forward
#kubectl port-forward svc/argocd-server -n argocd 8080:443 &

