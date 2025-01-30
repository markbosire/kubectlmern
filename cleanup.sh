#!/bin/bash

# Function to check if command exists
check_command() {
    if ! command -v $1 &> /dev/null; then
        echo "$1 could not be found. Please install it first."
        exit 1
    fi
}

# Check required commands
check_command "gcloud"
check_command "kubectl"

# Configuration variables
PROJECT_ID=$(gcloud config get-value project)
CLUSTER_NAME="mern-cluster"
CLUSTER_ZONE="us-central1-a"

echo "🧹 Starting cleanup process..."

# Delete Kubernetes resources
echo "📌 Deleting Kubernetes deployments and services..."
kubectl delete deployment --all
kubectl delete service --all
kubectl delete secret --all
kubectl delete configmap --all

# Delete static IP addresses
delete_static_ip() {
    local name=$1
    if gcloud compute addresses list | grep -q $name; then
        echo "🗑️ Deleting static IP: $name..."
        gcloud compute addresses delete $name --region=us-central1 --quiet
    fi
}

echo "🌐 Deleting static IPs..."
delete_static_ip "frontend-static-ip"
delete_static_ip "backend-static-ip"
delete_static_ip "mongo-express-static-ip"

# Delete GKE cluster
if gcloud container clusters list | grep -q $CLUSTER_NAME; then
    echo "🗑️ Deleting GKE cluster: $CLUSTER_NAME..."
    gcloud container clusters delete $CLUSTER_NAME --zone $CLUSTER_ZONE --quiet
fi

echo "✅ Cleanup completed successfully!"

