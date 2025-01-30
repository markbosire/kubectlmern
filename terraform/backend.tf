terraform {
  backend "gcs" {
    bucket = "mern-tfstate-onyancha-ni-goat"  # Must match google_storage_bucket.tfstate.name
    prefix = "terraform/state"  # Path prefix for state files
  }
}