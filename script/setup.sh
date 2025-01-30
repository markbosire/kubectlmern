#!/bin/bash



# Function to check if command exists
check_command() {
    if ! command -v $1 &> /dev/null; then
        echo "$1 could not be found. Please install it first."
      
    fi
}

# Check required commands
check_command "gcloud"
check_command "kubectl"
check_command "docker"

# Configuration variables
PROJECT_ID=$(gcloud config get-value project)   # Replace with your GCP project ID
CLUSTER_NAME="mern-cluster"
CLUSTER_ZONE="us-central1-a"
MACHINE_TYPE="e2-medium"

echo "🚀 Starting deployment process..."

# Install gke-gcloud-auth-plugin if not already installed
if ! command -v gke-gcloud-auth-plugin &> /dev/null; then
    echo "Installing gke-gcloud-auth-plugin..."
    sudo apt-get install -y google-cloud-sdk-gke-gcloud-auth-plugin
fi



# Create GKE cluster if it doesn't exist
if ! gcloud container clusters list | grep -q $CLUSTER_NAME; then
    echo "🌟 Creating GKE cluster..."
    gcloud container clusters create $CLUSTER_NAME \
        --zone=$CLUSTER_ZONE \
        --cluster-version=$CLUSTER_VERSION \
        --machine-type=$MACHINE_TYPE \
        --num-nodes=3 \
        --disk-size=50
fi

# Get cluster credentials
echo "🔑 Getting cluster credentials..."
gcloud container clusters get-credentials $CLUSTER_NAME --zone $CLUSTER_ZONE

# Create static IPs if they don't exist
create_static_ip() {
    local name=$1
    if ! gcloud compute addresses list | grep -q $name; then
        echo "Creating static IP: $name..."
        gcloud compute addresses create $name --region=us-central1  # Use the cluster's region
    fi
}

echo "🌐 Creating static IPs..."
create_static_ip "frontend-static-ip"
create_static_ip "backend-static-ip"
create_static_ip "mongo-express-static-ip"

# Get static IPs
FRONTEND_STATIC_IP=$(gcloud compute addresses describe frontend-static-ip --region=us-central1 --format='get(address)')
BACKEND_STATIC_IP=$(gcloud compute addresses describe backend-static-ip --region=us-central1 --format='get(address)')
MONGO_EXPRESS_STATIC_IP=$(gcloud compute addresses describe mongo-express-static-ip --region=us-central1 --format='get(address)')

echo "Static IPs:"
echo "Frontend: $FRONTEND_STATIC_IP"
echo "Backend: $BACKEND_STATIC_IP"
echo "Mongo Express: $MONGO_EXPRESS_STATIC_IP"

# Build and push Docker images
echo "🏗️ Building and pushing Docker images..."

# Backend
cd simplemern
docker build -t markbosire/simple-mern-backend:latest .
docker push markbosire/simple-mern-backend:latest

# Frontend
cd client
docker build \
    --build-arg VITE_API_IP="${BACKEND_STATIC_IP}" \
    -t markbosire/simple-mern-frontend:latest .
docker push markbosire/simple-mern-frontend:latest
cd ../..

# Export variables for envsubst
export FRONTEND_STATIC_IP
export BACKEND_STATIC_IP
export MONGO_EXPRESS_STATIC_IP

# Apply Kubernetes configurations
echo "🚀 Applying Kubernetes configurations..."

# List of YAML files to apply
YAML_FILES=(
    "app-config.yaml"
    "mongo-config.yaml"
    "mongo-secret.yaml"
    "frontend-app.yaml"
    "backend-app.yaml"
    "mongo-app.yaml"
    "mongo-express.yaml"
)

# Apply each YAML file with environment variable substitution
for file in "${YAML_FILES[@]}"; do
    echo "Applying $file..."
    envsubst < $file | kubectl apply -f -
done

# Wait for deployments to be ready
echo "⏳ Waiting for deployments to be ready..."
kubectl wait --for=condition=available deployment --all --timeout=300s

# Get external IPs and ports
echo "📊 Deployment complete! Here are your service endpoints:"
echo "Frontend: http://$FRONTEND_STATIC_IP"
echo "Backend: http://$BACKEND_STATIC_IP:3000"
echo "Mongo Express: http://$MONGO_EXPRESS_STATIC_IP:8081"

echo "✅ Deployment completed successfully!"
