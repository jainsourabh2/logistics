variable "services" {
  type = list(string)
  default = ["bigtable.googleapis.com","compute.googleapis.com","iam.googleapis.com","run.googleapis.com","cloudbilling.googleapis.com","containerregistry.googleapis.com","dns.googleapis.com","bigquery.googleapis.com","pubsub.googleapis.com","dataflow.googleapis.com","compute.googleapis.com","cloudbuild.googleapis.com"]
}

resource "google_project_service" "enable_api" {
  for_each = toset(var.services)
  project = google_project.terraform_generated_project.project_id
  service = each.value
  disable_on_destroy = true
}