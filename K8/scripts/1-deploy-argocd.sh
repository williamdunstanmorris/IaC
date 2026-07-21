#!/bin/bash

# Create namespace
kubectl create namespace argocd

# Install argocd with Helm
helm install argo ./K8/helm/argo-cd --namespace argocd

#  Default namespace for kubectl config must be set to argocd. This is only needed for the following commands since the previous commands have -n argocd already:
kubectl config set-context --current --namespace=argocd

# Change the argocd-server service type to LoadBalancer
kubectl patch svc argo-argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'

# You can retrieve this IP with
kubectl get svc argo-argocd-server -n argocd

# Port Forward
#kubectl port-forward svc/argocd-server -n argocd 8080:443 &

