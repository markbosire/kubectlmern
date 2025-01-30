output "jenkins_ip" {
  value = google_compute_instance.jenkins-vm.network_interface[0].access_config[0].nat_ip
}

output "frontend_ip" {
  value = google_compute_address.frontend.address
}

output "backend_ip" {
  value = google_compute_address.backend.address
}

output "mongo_express_ip" {
  value = google_compute_address.mongo-express.address
}