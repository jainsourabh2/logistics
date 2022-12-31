resource "null_resource" "generate_template" {

 provisioner "local-exec" {
    command = "./dataflow_generate_template.sh ${var.project}"
  }
}

resource "google_dataflow_job" "logistics_streaming_dataflow_bq_bigtable" {
    name = "logistics_streaming_dataflow_bq_bigtable"
    template_gcs_path = "gs://customer-demos-asia-south1/templates/logistics-streaming-bq-bigtable"
    temp_gcs_location = "gs://customer-demos-asia-south1/temp"
    enable_streaming_engine = true
    on_delete = "cancel"
    project = "on-prem-project-337210"
    region = "asia-south1"
    subnetwork = "regions/asia-south1/subnetworks/on-prem-subnet-mumbai"
    depends_on = [null_resource.generate_template]
    parameters = {
        input_topic = "projects/on-prem-project-337210/topics/vitaming"
  }
}