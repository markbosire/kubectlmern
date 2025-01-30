pipeline {
    agent any
    environment {
        FRONTEND_IMAGE = "markbosire/simple-mern-frontend"
        BACKEND_IMAGE = "markbosire/simple-mern-backend"
        GCP_PROJECT = "onyancha-ni-goat"
        GKE_CLUSTER = "express-mern-gke-cluster"
        GKE_ZONE = "us-central1-a"
        
        // Static IPs from GCP setup
        FRONTEND_STATIC_IP = "34.122.242.94"  // Replace with your actual IP
        BACKEND_STATIC_IP = "34.134.167.178"   // Replace with your actual IP
        MONGO_EXPRESS_STATIC_IP = "104.155.176.58" // Replace with your actual IP
        IMAGE_TAG = "${env.BUILD_ID}"
    }
    stages {
        stage('Checkout') {
            steps {
                git url: 'https://github.com/markbosire/kubectlmern.git', branch: 'main'
            }
        }
        
        stage('Print Static IPs') {
            steps {
                script {
                    echo "Frontend: ${env.FRONTEND_STATIC_IP}"
                    echo "Backend: ${env.BACKEND_STATIC_IP}"
                    echo "Mongo Express: ${env.MONGO_EXPRESS_STATIC_IP}"
                }
            }
        }
        
        stage('Build Docker Images') {
            steps {
                script {
                    // Frontend with build argument
                    docker.build("${FRONTEND_IMAGE}:${env.BUILD_ID}", './simplemern/client') {
                        buildArgs "VITE_API_IP": "${env.FRONTEND_STATIC_IP}"
                    }
                    
                    // Backend
                    docker.build("${BACKEND_IMAGE}:${env.BUILD_ID}", './simplemern')
                }
            }
        }
        
        stage('Push to Docker Hub') {
            steps {
                script {
                    docker.withRegistry('https://registry.hub.docker.com', 'dockerhub-creds') {
                        docker.image("${FRONTEND_IMAGE}:${env.BUILD_ID}").push()
                        docker.image("${BACKEND_IMAGE}:${env.BUILD_ID}").push()
                    }
                }
            }
        }
        
        stage('Deploy to GKE') {
            steps {
                script {
                    withCredentials([file(credentialsId: 'gcp-service-account', variable: 'GCP_KEY')]) {
                        sh 'gcloud auth activate-service-account --key-file=$GCP_KEY'
                        sh "gcloud container clusters get-credentials ${GKE_CLUSTER} --zone ${GKE_ZONE} --project ${GCP_PROJECT}"
                        
                        // Inject static IPs into manifests
                        sh """
                         envsubst < kubernetes/frontend-app.yaml > kubernetes/frontend-app.yaml
                         envsubst < kubernetes/backend-app.yaml > kubernetes/backend-app.yaml
                         envsubst < kubernetes/mongo-express.yaml > kubernetes/mongo-express.yaml
                         envsubst < kubernetes/app-config..yaml > kubernetes/app-config.yaml
                       
                        """
                        
                        // Apply configurations
                        sh """
                            kubectl apply -f kubernetes/mongo-secret.yaml
                            kubectl apply -f kubernetes/mongo-config.yaml
                            kubectl apply -f kubernetes/mongo-app.yaml
                            kubectl apply -f kubernetes/app-config.yaml
                            kubectl apply -f kubernetes/backend-app.yaml
                            kubectl apply -f kubernetes/frontend-app.yaml
                            kubectl apply -f kubernetes/mongo-express.yaml
                        """
                    }
                }
            }
        }
    }
}