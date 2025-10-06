output "cloud_function_uri" {
  value       = google_cloudfunctions2_function.api_function.service_config[0].uri
  description = "Public URL for the Gen 2 HTTP function"
}
output "static_website_url" {
  value       = "https://storage.googleapis.com/${google_storage_bucket.static_site.name}/index.html"
  description = "URL to the static site index page"
}
