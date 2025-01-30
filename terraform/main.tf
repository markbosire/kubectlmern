
# VPC Network
resource "google_compute_network" "jenkins-mern-vpc" {
  name                    = "jenkins-mern-vpc"
  auto_create_subnetworks = false
}

# Subnet
resource "google_compute_subnetwork" "jenkins-mern-subnet" {
  name          = "jenkins-mern-subnet"
  ip_cidr_range = "10.0.0.0/24"
  region        = var.region
  network       = google_compute_network.jenkins-mern-vpc.id
}

# Firewall Rules
resource "google_compute_firewall" "allow-ssh" {
  name    = "allow-mern-ssh"
  network = google_compute_network.jenkins-mern-vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "allow-jenkins" {
  name    = "allow-mern-jenkins"
  network = google_compute_network.jenkins-mern-vpc.name

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }

  source_ranges = ["0.0.0.0/0"]
}

# Jenkins VM
resource "google_compute_instance" "jenkins-vm" {
  name         = "jenkins-mern-vm"
  machine_type = "e2-medium"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      size  = 10
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.jenkins-mern-subnet.self_link
    access_config {}
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    apt update
    apt-get install -y openjdk-17-jdk kubectl git curl google-cloud-sdk-gke-gcloud-auth-plugin
    wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
    echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" https://pkg.jenkins.io/debian-stable binary/ | tee /etc/apt/sources.list.d/jenkins.list > /dev/null
    apt-get update
    apt-get install -y jenkins
    systemctl start jenkins
    systemctl enable jenkins
    curl -sSL https://get.docker.com/ | sh
    usermod -aG docker jenkins
    systemctl restart jenkins
  EOF

  service_account {
    email  = "jenkins-gke-deployer@${var.project_id}.iam.gserviceaccount.com"
    scopes = ["cloud-platform"]
  }
}

# GKE Cluster
resource "google_container_cluster" "mern-cluster" {
  name     = "express-mern-gke-cluster"
  location = var.zone

  remove_default_node_pool = true
  initial_node_count       = 1

  network    = google_compute_network.jenkins-mern-vpc.self_link
  subnetwork = google_compute_subnetwork.jenkins-mern-subnet.self_link
}

resource "google_container_node_pool" "mern-node-pool" {
  name       = "mern-node-pool"
  location   = var.zone
  cluster    = google_container_cluster.mern-cluster.name
  node_count = 3

  node_config {
    machine_type    = "e2-medium"
    disk_size_gb    = 50
    service_account = "jenkins-gke-deployer@${var.project_id}.iam.gserviceaccount.com"
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}

# Static IPs
resource "google_compute_address" "frontend" {
  name   = "frontend-static-ip"
  region = var.region
}

resource "google_compute_address" "backend" {
  name   = "backend-static-ip"
  region = var.region
}

resource "google_compute_address" "mongo-express" {
  name   = "mongo-express-static-ip"
  region = var.region
}
