resource "google_pubsub_topic" "pubsub_topic" {
  name          = "logistics"
  project       = google_project.terraform_generated_project.project_id
  depends_on = [google_project_iam_member.dataflow_roles_binding]
}