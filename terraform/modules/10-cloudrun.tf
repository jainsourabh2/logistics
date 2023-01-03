resource "google_service_account" "sa_ingest_pubsub" {
  account_id    = "sa-ingest-pubsub"
  display_name  = "service-account_ingest_pubsub"
  project       = google_project.terraform_generated_project.project_id
  depends_on = [google_dataflow_job.logistics_streaming_dataflow_bq_bigtable]
}

resource "google_project_iam_member" "sa_ingest_pubsub_roles_binding" {
  for_each = toset([
    "roles/owner"
  ])
  role = each.key
  member  = "serviceAccount:${google_service_account.sa_ingest_pubsub.email}"
  project = google_project.terraform_generated_project.project_id
  depends_on = [google_service_account.sa_ingest_pubsub]
}

resource "null_resource" "grant_execute_permission_cloudrun_ingest_pubsub" {

 provisioner "local-exec" {
    command = "chmod +x ../ingest-pubsub/cloudrun_wrapper.sh"
  }
  depends_on = [google_project_iam_member.sa_ingest_pubsub_roles_binding]
}

resource "null_resource" "build_ingest_pubsub_container" {

 provisioner "local-exec" {
    command = "../ingest-pubsub/cloudrun_wrapper.sh ${google_project.terraform_generated_project.project_id}"
  }
  depends_on = [null_resource.grant_execute_permission_cloudrun_ingest_pubsub]
}

# Create the Cloud Run service
resource "google_cloud_run_service" "run_service_ingest_pubsub" {
  name = "ingest-pubsub"
  location = var.region
  project = google_project.terraform_generated_project.project_id
  template {
    spec {
      containers {
        image = "gcr.io/${google_project.terraform_generated_project.project_id}/ingest-pubsub:latest"
      }
      service_account_name = google_service_account.sa_ingest_pubsub.email
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  autogenerate_revision_name = true

  # Waits for the Cloud Run API to be enabled
  depends_on = [null_resource.build_ingest_pubsub_container]
}

# Display the service URL
output "service_url_ingest_pubsub" {
  value = google_cloud_run_service.run_service_ingest_pubsub.status[0].url
}

resource "google_service_account" "sa_bigtable_apis" {
  account_id    = "sa-bigtable-apis"
  display_name  = "service-account_bigtable_apis"
  project       = google_project.terraform_generated_project.project_id
  depends_on = [google_cloud_run_service.run_service_ingest_pubsub]
}

resource "google_project_iam_member" "sa_bigtable_apis_roles_binding" {
  for_each = toset([
    "roles/owner"
  ])
  role = each.key
  member  = "serviceAccount:${google_service_account.sa_bigtable_apis.email}"
  project = google_project.terraform_generated_project.project_id
  depends_on = [google_service_account.sa_bigtable_apis]
}

resource "null_resource" "grant_execute_permission_cloudrun_bigtable_apis" {

 provisioner "local-exec" {
    command = "chmod +x ../customer-backend-tracker/cloudrun_wrapper.sh"
  }
  depends_on = [google_project_iam_member.sa_bigtable_apis_roles_binding]
}

resource "null_resource" "build_bigtable_apis_container" {

 provisioner "local-exec" {
    command = "../customer-backend-tracker/cloudrun_wrapper.sh ${google_project.terraform_generated_project.project_id}"
  }
  depends_on = [null_resource.grant_execute_permission_cloudrun_bigtable_apis]
}

# Create the Cloud Run service
resource "google_cloud_run_service" "run_service_bigtable_apis" {
  name = "bigtable-apis"
  location = var.region
  project = google_project.terraform_generated_project.project_id
  template {
    spec {
      containers {
        image = "gcr.io/${google_project.terraform_generated_project.project_id}/bigtable-apis:latest"
      }
      service_account_name = google_service_account.sa_bigtable_apis.email
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  autogenerate_revision_name = true

  # Waits for the Cloud Run API to be enabled
  depends_on = [null_resource.build_bigtable_apis_container]
}

# Display the service URL
output "service_url_bigtable_apis" {
  value = google_cloud_run_service.run_service_bigtable_apis.status[0].url
}

resource "google_service_account" "sa_order_frontend" {
  account_id    = "sa-order-frontend"
  display_name  = "service-account_order_frontend"
  project       = google_project.terraform_generated_project.project_id
  depends_on = [google_cloud_run_service.run_service_bigtable_apis]
}

resource "google_project_iam_member" "sa_order_frontend_roles_binding" {
  for_each = toset([
    "roles/owner"
  ])
  role = each.key
  member  = "serviceAccount:${google_service_account.sa_order_frontend.email}"
  project = google_project.terraform_generated_project.project_id
  depends_on = [google_service_account.sa_order_frontend]
}

resource "null_resource" "grant_execute_permission_cloudrun_order_frontend" {

 provisioner "local-exec" {
    command = "chmod +x ../customer-frontend-tracker/cloudrun_wrapper.sh"
  }
  depends_on = [google_cloud_run_service.run_service_bigtable_apis]
}

resource "null_resource" "build_order_frontend_container" {

 provisioner "local-exec" {
    command = "../customer-frontend-tracker/cloudrun_wrapper.sh ${google_project.terraform_generated_project.project_id} ${google_cloud_run_service.run_service_bigtable_apis.status[0].url}"
  }
  depends_on = [null_resource.grant_execute_permission_cloudrun_order_frontend]
}

# Create the Cloud Run service
resource "google_cloud_run_service" "run_service_order_frontend" {
  name = "order-frontend"
  location = var.region
  project = google_project.terraform_generated_project.project_id
  template {
    spec {
      containers {
        image = "gcr.io/${google_project.terraform_generated_project.project_id}/order-frontend:latest"
      }
    service_account_name = google_service_account.sa_order_frontend.email
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  autogenerate_revision_name = true

  # Waits for the Cloud Run API to be enabled
  depends_on = [null_resource.build_order_frontend_container]
}

# Display the service URL
output "service_url_order_frontend" {
  value = google_cloud_run_service.run_service_order_frontend.status[0].url
}


resource "null_resource" "grant_execute_permission_test_harness" {

 provisioner "local-exec" {
    command = "chmod +x ../test-harness/wrapper.sh"
  }
  depends_on = [google_cloud_run_service.run_service_order_frontend]
}

resource "null_resource" "replace_ingest_url" {

 provisioner "local-exec" {
    command = "../test-harness/wrapper.sh  ${google_cloud_run_service.run_service_ingest_pubsub.status[0].url}"
  }
  depends_on = [null_resource.grant_execute_permission_test_harness]
}