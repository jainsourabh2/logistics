resource "null_resource" "grant_execute_permission" {

 provisioner "local-exec" {
    command = "chmod +x ../dataflow-pipeline/dataflow_wrapper.sh"
  }
  depends_on = [google_bigtable_app_profile.bigtable-app-profile]
}

resource "null_resource" "generate_template" {

 provisioner "local-exec" {
    command = "../dataflow-pipeline/dataflow_wrapper.sh ${google_project.terraform_generated_project.project_id}"
  }
  depends_on = [null_resource.grant_execute_permission]
}


resource "google_dataflow_job" "logistics_streaming_dataflow_bq_bigtable" {
    name = "logistics_streaming_dataflow_bq_bigtable"
    template_gcs_path = "gs://${var.project}/templates/logistics-streaming-bq-bigtable"
    temp_gcs_location = "gs://${var.project}/temp"
    enable_streaming_engine = true
    on_delete = "cancel"
    project = var.project
    region = var.region
    subnetwork = "regions/${var.region}/subnetworks/${google_compute_subnetwork.vpc_subnetwork.name}"
    depends_on = [null_resource.generate_template]
    service_account_email = google_service_account.sa_name.email
}