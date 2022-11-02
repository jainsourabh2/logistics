resource "google_pubsub_topic" "topic" {
    name     = var.topic
}

resource "google_storage_bucket" "bucket1" {
    name          = "tf-test-bucket1"
    location      = var.region
    force_destroy = true
}

resource "google_storage_bucket" "bucket2" {
    name          = "tf-test-bucket2"
    location      = var.region
    force_destroy = true
}

resource "google_dataflow_job" "pubsub_stream" {
    name = local.dataflow_job_name
    template_gcs_path = "gs://my-bucket/templates/template_file"
    temp_gcs_location = "gs://my-bucket/tmp_dir"
    enable_streaming_engine = true
    parameters = {
      inputFilePattern = "${google_storage_bucket.bucket1.url}/*.json"
      outputTopic    = google_pubsub_topic.topic.id
    }
    transform_name_mapping = {
        name = "test_job"
        env = "test"
    }
    on_delete = "cancel"
}

locals {
  dataflow_job_name   = "pubsub-dataflow-bigquery-bigtable"
}