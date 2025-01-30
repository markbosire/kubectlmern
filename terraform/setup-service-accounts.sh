#!/bin/bash

# Variables
PROJECT_ID=$(gcloud config get-value project)
BUCKET_NAME="mern-tfstate-${PROJECT_ID}"  # Unique bucket name

# Create Terraform Service Account
gcloud iam service-accounts create terraform-infra-manager \
  --display-name="Terraform Infrastructure Manager Service Account"

# Assign Granular Roles to Terraform SA
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:terraform-infra-manager@$PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/compute.admin"

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:terraform-infra-manager@$PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/container.admin"

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:terraform-infra-manager@$PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/iam.serviceAccountUser"

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:terraform-infra-manager@$PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/storage.admin"  # For managing GCS buckets

# Generate Key File for Terraform SA
gcloud iam service-accounts keys create keys/terraform-infra-manager-key.json \
  --iam-account=terraform-infra-manager@$PROJECT_ID.iam.gserviceaccount.com

# Create Jenkins Service Account
gcloud iam service-accounts create jenkins-gke-deployer \
  --display-name="Jenkins GKE Deployer Service Account"

# Assign Granular Roles to Jenkins SA
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:jenkins-gke-deployer@$PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/container.developer"

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:jenkins-gke-deployer@$PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/storage.objectViewer"

# Generate Key File for Jenkins SA
gcloud iam service-accounts keys create keys/jenkins-gke-deployer-key.json \
  --iam-account=jenkins-gke-deployer@$PROJECT_ID.iam.gserviceaccount.com

# Create GCS Bucket for Terraform State
if ! gcloud storage ls -b gs://$BUCKET_NAME &>/dev/null; then
  echo "Creating GCS bucket: $BUCKET_NAME..."
  gcloud storage buckets create gs://$BUCKET_NAME 
  gcloud storage buckets update gs://$BUCKET_NAME --versioning
  echo "GCS bucket created successfully!"
else
  echo "GCS bucket already exists: $BUCKET_NAME"
fi

echo "Service accounts, keys, and GCS bucket created successfully!"