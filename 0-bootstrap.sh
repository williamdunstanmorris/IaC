#!/bin/bash
set -e

PROJECT_ID=$(gcloud config get project)
CLUSTER_NAME="app-cluster"
ZONE="europe-west3-b"

echo "→ Getting cluster credentials..."
# Creates or updates .kube/config. Holds public cluster's public (but not authed) IP address and
# cert data.
gcloud container clusters get-credentials "$CLUSTER_NAME" \
  --zone "$ZONE" \
  --project "$PROJECT_ID"

gcloud components update

gcloud container clusters get-credentials app-cluster \
  --zone "$ZONE"

# SSH via bastion
#gcloud compute ssh gke-bastion-host \
#    --zone="$ZONE" \
#    --tunnel-through-iap \
#    -- -D 8888 -N -q

# Create proxy
#export HTTPS_PROXY=socks5://localhost:8888

kubectl get namespaces

gcloud container clusters describe "$CLUSTER_NAME" \
    --zone="$ZONE" \
    --format json

gcloud container node-pools describe workload \
    --cluster="$CLUSTER_NAME" \
    --zone="$ZONE"
