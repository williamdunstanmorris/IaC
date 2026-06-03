#!/bin/bash
set -e

PROJECT_ID=$(gcloud config get project)
CLUSTER_NAME="app-cluster"
ZONE="europe-west3-b"

echo "→ Getting cluster credentials..."
# Creates or updates .kube/config. Holds public cluster's public (but not authed) IP address and
# cert data.
gcloud container clusters get-credentials $CLUSTER_NAME \
  --zone $ZONE \
  --project "$PROJECT_ID"

gcloud components update

gcloud container clusters get-credentials app-cluster \
  --zone $ZONE

kubectl get namespaces

gcloud container clusters describe $CLUSTER_NAME \
    --zone=$ZONE \
    --format json

gcloud container node-pools describe default-pool \
    --cluster=$CLUSTER_NAME \
    --zone=$ZONE
