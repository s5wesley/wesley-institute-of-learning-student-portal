#############################
# Static website bucket
#############################
resource "google_storage_bucket" "static_site" {
  name     = var.bucket_name
  location = var.bucket_location

  website {
    main_page_suffix = "index.html"
    not_found_page   = "error.html"
  }

  uniform_bucket_level_access = true
}

# Make website objects public
resource "google_storage_bucket_iam_member" "public_read" {
  bucket = google_storage_bucket.static_site.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}

# Upload *.html files from ./website
resource "google_storage_bucket_object" "html_files" {
  for_each     = fileset("${path.module}/website", "*.html")
  name         = each.value
  bucket       = google_storage_bucket.static_site.name
  source       = "${path.module}/website/${each.value}"
  content_type = "text/html"
}

#############################
# Function source bucket + zip object
#############################
resource "google_storage_bucket" "function_source" {
  name     = "${var.bucket_name}-function"
  location = var.bucket_location

  # Keep defaults (UBLA false/true as you prefer); set explicitly if needed:
  # uniform_bucket_level_access = true
}

# Uses data.archive_file.function_zip from providers.tf
# Creates a cache-busting object name based on the zip content hash
resource "google_storage_bucket_object" "function_zip" {
  name   = "function-${data.archive_file.function_zip.output_md5}.zip"
  bucket = google_storage_bucket.function_source.name
  source = data.archive_file.function_zip.output_path
}

#############################
# Cloud Functions (Gen 2)
#############################
resource "google_cloudfunctions2_function" "api_function" {
  name        = var.function_name
  location    = var.region # e.g., "us-central1"
  description = "Student registration HTTP function (Gen 2)"

  build_config {
    runtime     = "nodejs20"
    entry_point = "registerStudent"

    source {
      storage_source {
        bucket = google_storage_bucket.function_source.name
        object = google_storage_bucket_object.function_zip.name
      }
    }

    environment_variables = {
      FIRESTORE_PROJECT = var.project_id
    }
  }

  service_config {
    available_memory   = "256M"
    timeout_seconds    = 60
    ingress_settings   = "ALLOW_ALL"
    max_instance_count = 10

    environment_variables = {
      FIRESTORE_PROJECT = var.project_id
    }
  }
}

# ✅ Grant public invoke on the underlying Cloud Run service (Gen2-correct)
resource "google_cloud_run_v2_service_iam_member" "public_invoker" {
  project  = var.project_id
  location = var.region
  name     = google_cloudfunctions2_function.api_function.service_config[0].service
  role     = "roles/run.invoker"
  member   = "allUsers"

  depends_on = [google_cloudfunctions2_function.api_function]
}
