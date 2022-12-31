resource "null_resource" "grant_execute_permission" {

 provisioner "local-exec" {
    command = "chmod +x ../dataflow_wrapper.sh"
  }
}

resource "null_resource" "generate_template" {

 provisioner "local-exec" {
    command = "../dataflow_wrapper.sh ${var.project}"
  }
  depends_on = [null_resource.grant_execute_permission]
}

resource "google_dataflow_job" "logistics_streaming_dataflow_bq_bigtable" {
    name = "logistics_streaming_dataflow_bq_bigtable"
    template_gcs_path = "gs://${var.project}/templates/logistics-streaming-bq-bigtable"
    temp_gcs_location = "gs://${var.project}/temp"
    enable_streaming_engine = true
    on_delete = "cancel"
    project = "on-prem-project-337210"
    region = "asia-south1"
    subnetwork = "regions/asia-south1/subnetworks/on-prem-subnet-mumbai"
    depends_on = [null_resource.generate_template]
}