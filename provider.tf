terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    # This provider is built in to Terraform, no extra install needed
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.4" # or latest stable
    }
  }
}

# Google Cloud provider
provider "google" {
  project = var.project_id
  region  = var.region # Cloud Functions region (e.g. "us-central1")
}

# (Optional) if you also want to use the bucket location variable directly
# provider "google-beta" {
#   project = var.project_id
#   region  = var.region
# }

# Build your Cloud Function zip automatically from ./function_src
data "archive_file" "function_zip" {
  type        = "zip"
  source_dir  = "${path.module}/function_src"
  output_path = "${path.module}/function.zip"
}
