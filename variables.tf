variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

# Region for Cloud Functions / Google provider (e.g., "us-central1")
variable "region" {
  description = "GCP region for Cloud Functions (Gen 2) and provider"
  type        = string
}

# Location for buckets (e.g., "US-CENTRAL1" or "US" for multi-region)
variable "bucket_location" {
  description = "Location for Google Cloud Storage buckets (regional or multi-regional)"
  type        = string
}

# Name of your static site bucket (no suffix)
variable "bucket_name" {
  description = "Static site bucket name (without -function suffix)"
  type        = string
}

variable "function_name" {
  description = "Cloud Function (Gen 2) name"
  type        = string
}
