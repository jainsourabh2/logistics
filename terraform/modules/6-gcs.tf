resource "google_storage_bucket" "gcs_master_data" {
  name          = google_project.terraform_generated_project.project_id
  location      = var.region
  force_destroy = true
  project       = google_project.terraform_generated_project.project_id
  public_access_prevention = "enforced"
  uniform_bucket_level_access = true
  depends_on = [google_pubsub_topic.pubsub_topic]
}

variable "load_files" {
  type = list(string)
  default = ["suppliers.csv","warehouse.csv","warehouse_local.csv"]
}

resource "google_storage_bucket_object" "load_bigquery_master_data" {
  for_each  = toset(var.load_files)
  name      = each.value
  source    = each.value
  bucket    = google_storage_bucket.gcs_master_data.name
  depends_on = [google_storage_bucket.gcs_master_data]
}