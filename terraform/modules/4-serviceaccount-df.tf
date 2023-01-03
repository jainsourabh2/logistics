resource "google_service_account" "sa_name" {
  account_id    = "tf-sa-name"
  display_name  = "terraform-created-service-account"
  project       = google_project.terraform_generated_project.project_id
  depends_on = [google_compute_subnetwork.vpc_subnetwork]
}

resource "google_project_iam_member" "dataflow_roles_binding" {
  for_each = toset([
    "roles/owner",
    "roles/bigquery.admin",
    "roles/bigtable.admin",
    "roles/storage.admin",
    "roles/storage.objectAdmin",
    "roles/pubsub.admin",
    "roles/dataflow.admin"
  ])
  role = each.key
  member  = "serviceAccount:${google_service_account.sa_name.email}"
  project = google_project.terraform_generated_project.project_id
  depends_on = [google_service_account.sa_name]
}
