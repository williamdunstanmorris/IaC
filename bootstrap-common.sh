#!/bin/bash

# https://dev.to/jajera/top-20-kubectl-commands-for-everyday-kubernetes-workflows-3m3e
# Get commands
kubectl get pods -A

kubectl get deployments --all-namespaces

# Confirm the GatewayClasses are installed in your cluster
kubectl get gatewayclass


