#export TF_LOG="DEBUG"

#module "gcp" {
#  source            = "./modules"
#  name              = var.name
#  gcp_project       = var.gcp_project
#  region            = var.region
#  zone              = var.zone
#  subnet_cidr_range = var.subnet_cidr_range
#}

resource "random_id" "random_suffix" {
  keepers = {
    first = "${timestamp()}"
  }     
  byte_length = 10
}

#roles/resourcemanager.folderCreator permission is needed
resource "google_folder" "logistics-demo" {
  display_name = var.folder
  parent       = "organizations/${var.organization}"
}

#roles/resourcemanager.projectCreator permission is needed
resource "google_project" "terraform_generated_project" {
  name       = var.project
  project_id = var.project
  billing_account = var.billing-account
  folder_id  = google_folder.logistics-demo.name
}

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

resource "google_compute_network" "vpc_network" {
  project                 = google_project.terraform_generated_project.project_id
  name                    = "terraform-network-logistics-demo"
  auto_create_subnetworks = false
  mtu                     = 1460
  depends_on = [google_project_service.enable_api]
}

resource "google_compute_subnetwork" "vpc_subnetwork" {
  name          = "terraform-sub-network-logistics-demo"
  ip_cidr_range = "10.0.0.0/24"
  region        = var.region
  private_ip_google_access = true
  network       = google_compute_network.vpc_network.id
  project       = google_project.terraform_generated_project.project_id
}

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

resource "google_pubsub_topic" "pubsub_topic" {
  name          = "logistics"
  project       = google_project.terraform_generated_project.project_id
  depends_on = [google_project_iam_member.dataflow_roles_binding]
}

resource "google_storage_bucket" "gcs_master_data" {
  name          = google_project.terraform_generated_project.project_id
  location      = var.region
  force_destroy = false
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

resource "google_bigquery_dataset" "dataset" {
  dataset_id    = "logistics"
  friendly_name = "logistics"
  description   = "Terraform Created Dataset"
  location      = var.region
  project       = google_project.terraform_generated_project.project_id
  depends_on    = [google_storage_bucket_object.load_bigquery_master_data]
}

resource "google_bigquery_table" "table" {
  dataset_id = google_bigquery_dataset.dataset.dataset_id
  table_id   = "logistics"
  project    = google_project.terraform_generated_project.project_id

  time_partitioning {
    type  = "DAY"
    field = "transaction_time"
    require_partition_filter = true
  }

  clustering = ["supplier_id","local_warehouse","warehouse"]

  schema = <<EOF
[
  {
    "mode": "NULLABLE",
    "name": "status",
    "type": "STRING"
  },
  {
    "mode": "NULLABLE",
    "name": "transaction_time",
    "type": "TIMESTAMP"
  },
  {
    "mode": "NULLABLE",
    "name": "item_id",
    "type": "INTEGER"
  },
  {
    "mode": "NULLABLE",
    "name": "customer_id",
    "type": "STRING"
  },
  {
    "mode": "NULLABLE",
    "name": "local_warehouse",
    "type": "INTEGER"
  },
  {
    "mode": "NULLABLE",
    "name": "customer_location",
    "type": "INTEGER"
  },
  {
    "mode": "NULLABLE",
    "name": "warehouse",
    "type": "INTEGER"
  },
  {
    "mode": "NULLABLE",
    "name": "supplier_id",
    "type": "INTEGER"
  },
  {
    "mode": "NULLABLE",
    "name": "package_id",
    "type": "STRING"
  },
  {
    "mode": "NULLABLE",
    "name": "price",
    "type": "INTEGER"
  }
]
EOF

}

resource "google_bigquery_table" "suppliers_table" {
  dataset_id = google_bigquery_dataset.dataset.dataset_id
  table_id   = "suppliers"
  project    = google_project.terraform_generated_project.project_id
  deletion_protection = false

  schema = <<EOF
[
  {
    "mode": "NULLABLE",
    "name": "code",
    "type": "INTEGER"
  },
  {
    "mode": "NULLABLE",
    "name": "city",
    "type": "STRING"
  },
  {
    "mode": "NULLABLE",
    "name": "city_ascii",
    "type": "STRING"
  },
  {
    "mode": "NULLABLE",
    "name": "lat",
    "type": "FLOAT"
  },
  {
    "mode": "NULLABLE",
    "name": "lng",
    "type": "FLOAT"
  },
  {
    "mode": "NULLABLE",
    "name": "country",
    "type": "STRING"
  },
  {
    "mode": "NULLABLE",
    "name": "iso2",
    "type": "STRING"
  },
  {
    "mode": "NULLABLE",
    "name": "iso3",
    "type": "STRING"
  },
  {
    "mode": "NULLABLE",
    "name": "admin_name",
    "type": "STRING"
  },
  {
    "mode": "NULLABLE",
    "name": "capital",
    "type": "STRING"
  },
  {
    "mode": "NULLABLE",
    "name": "population",
    "type": "INTEGER"
  },
  {
    "mode": "NULLABLE",
    "name": "id",
    "type": "INTEGER"
  },
  {
    "mode": "NULLABLE",
    "name": "Type",
    "type": "STRING"
  },
  {
    "mode": "NULLABLE",
    "name": "warehouse_code",
    "type": "INTEGER"
  },
  {
    "mode": "NULLABLE",
    "name": "local_warehouse_code",
    "type": "INTEGER"
  }
]
EOF

}

resource "google_bigquery_job" "suppliers_job" {
  job_id     = "sj-${random_id.random_suffix.hex}"
  location   = var.region
  project = google_project.terraform_generated_project.project_id


  load {
    source_uris = [
      "gs://${google_storage_bucket.gcs_master_data.name}/suppliers.csv",
    ]

    destination_table {
      project_id = google_bigquery_table.suppliers_table.project
      dataset_id = google_bigquery_table.suppliers_table.dataset_id
      table_id   = google_bigquery_table.suppliers_table.table_id
    }

    skip_leading_rows = 1

    write_disposition = "WRITE_TRUNCATE"
    create_disposition = "CREATE_IF_NEEDED"
    autodetect = true
  }
}


resource "google_bigquery_table" "warehouse_table" {
  dataset_id = google_bigquery_dataset.dataset.dataset_id
  table_id   = "warehouse"
  project    = google_project.terraform_generated_project.project_id
  deletion_protection = false

  schema = <<EOF
[
  {
    "mode": "NULLABLE",
    "name": "admin_name",
    "type": "STRING"
  },
  {
    "mode": "NULLABLE",
    "name": "code",
    "type": "INTEGER"
  },
  {
    "mode": "NULLABLE",
    "name": "city",
    "type": "STRING"
  },
  {
    "mode": "NULLABLE",
    "name": "city_ascii",
    "type": "STRING"
  },
  {
    "mode": "NULLABLE",
    "name": "lat",
    "type": "FLOAT"
  },
  {
    "mode": "NULLABLE",
    "name": "lng",
    "type": "FLOAT"
  },
  {
    "mode": "NULLABLE",
    "name": "country",
    "type": "STRING"
  },
  {
    "mode": "NULLABLE",
    "name": "iso2",
    "type": "STRING"
  },
  {
    "mode": "NULLABLE",
    "name": "iso3",
    "type": "STRING"
  },
  {
    "mode": "NULLABLE",
    "name": "admin_name_9",
    "type": "STRING"
  },
  {
    "mode": "NULLABLE",
    "name": "capital",
    "type": "STRING"
  },
  {
    "mode": "NULLABLE",
    "name": "population",
    "type": "INTEGER"
  },
  {
    "mode": "NULLABLE",
    "name": "id",
    "type": "INTEGER"
  },
  {
    "mode": "NULLABLE",
    "name": "Type",
    "type": "STRING"
  }
]
EOF

}

resource "google_bigquery_job" "warehouse_job" {
  job_id     = "wj-${random_id.random_suffix.hex}"
  location   = var.region
  project = google_project.terraform_generated_project.project_id

  load {
    source_uris = [
      "gs://${google_storage_bucket.gcs_master_data.name}/warehouse.csv",
    ]

    destination_table {
      project_id = google_bigquery_table.warehouse_table.project
      dataset_id = google_bigquery_table.warehouse_table.dataset_id
      table_id   = google_bigquery_table.warehouse_table.table_id
    }

    skip_leading_rows = 1

    write_disposition = "WRITE_TRUNCATE"
    create_disposition = "CREATE_IF_NEEDED"
    autodetect = true
  }
}

resource "google_bigquery_table" "warehouse_local_table" {
  dataset_id = google_bigquery_dataset.dataset.dataset_id
  table_id   = "warehouse_local"
  project    = google_project.terraform_generated_project.project_id
  deletion_protection = false

  schema = <<EOF
[
  {
    "mode": "NULLABLE",
    "name": "admin_name",
    "type": "STRING"
  },
  {
    "mode": "NULLABLE",
    "name": "code",
    "type": "INTEGER"
  },
  {
    "mode": "NULLABLE",
    "name": "city",
    "type": "STRING"
  },
  {
    "mode": "NULLABLE",
    "name": "city_ascii",
    "type": "STRING"
  },
  {
    "mode": "NULLABLE",
    "name": "lat",
    "type": "FLOAT"
  },
  {
    "mode": "NULLABLE",
    "name": "lng",
    "type": "FLOAT"
  },
  {
    "mode": "NULLABLE",
    "name": "country",
    "type": "STRING"
  },
  {
    "mode": "NULLABLE",
    "name": "iso2",
    "type": "STRING"
  },
  {
    "mode": "NULLABLE",
    "name": "iso3",
    "type": "STRING"
  },
  {
    "mode": "NULLABLE",
    "name": "admin_name_9",
    "type": "STRING"
  },
  {
    "mode": "NULLABLE",
    "name": "capital",
    "type": "STRING"
  },
  {
    "mode": "NULLABLE",
    "name": "population",
    "type": "INTEGER"
  },
  {
    "mode": "NULLABLE",
    "name": "id",
    "type": "INTEGER"
  },
  {
    "mode": "NULLABLE",
    "name": "Type",
    "type": "STRING"
  }
]
EOF

}

resource "google_bigquery_job" "warehouse_local_job" {
  job_id     = "wlj-${random_id.random_suffix.hex}"
  location   = var.region
  project = google_project.terraform_generated_project.project_id

  load {
    source_uris = [
      "gs://${google_storage_bucket.gcs_master_data.name}/warehouse_local.csv",
    ]

    destination_table {
      project_id = google_bigquery_table.warehouse_local_table.project
      dataset_id = google_bigquery_table.warehouse_local_table.dataset_id
      table_id   = google_bigquery_table.warehouse_local_table.table_id
    }

    skip_leading_rows = 1
    write_disposition = "WRITE_TRUNCATE"
    create_disposition = "CREATE_IF_NEEDED"
    autodetect = true
  }
}

resource "google_bigtable_instance" "bigtable-instance" {
  name = "logistics-inst"
  project    = google_project.terraform_generated_project.project_id
  deletion_protection  = "true"
  depends_on = [google_bigquery_table.table]
  cluster {
    cluster_id    = "logistics-cluster"
    num_nodes     = 1
    storage_type  = "HDD"
    zone          = var.zone
  }

  lifecycle {
    prevent_destroy = true
  }  

}

resource "google_bigtable_table" "bigtable-table-order" {
  name          = "logistics-order"
  instance_name = google_bigtable_instance.bigtable-instance.name
  project    = google_project.terraform_generated_project.project_id
  depends_on = [google_bigtable_instance.bigtable-instance]
  column_family {
    family = "delivery_stats"
  }  
  lifecycle {
    prevent_destroy = true
  }
}

resource "google_bigtable_table" "bigtable-table-customer" {
  name          = "logistics-customer"
  instance_name = google_bigtable_instance.bigtable-instance.name
  project    = google_project.terraform_generated_project.project_id  
  depends_on = [google_bigtable_instance.bigtable-instance]
  column_family {
    family = "delivery_stats"
  }
  lifecycle {
    prevent_destroy = true
  }
}

resource "google_bigtable_app_profile" "bigtable-app-profile" {
  instance        = google_bigtable_instance.bigtable-instance.name
  app_profile_id  = "logistics-app-profile"
  ignore_warnings = true
  project         = google_project.terraform_generated_project.project_id
  depends_on = [google_bigtable_table.bigtable-table-customer,google_bigtable_table.bigtable-table-order]
  single_cluster_routing {
    cluster_id                 = "logistics-cluster"
    allow_transactional_writes = true
  }
}

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
    service_account_name = "serviceAccount:${google_service_account.sa_ingest_pubsub.email}"
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
      service_account_name = "serviceAccount:${google_service_account.sa_bigtable_apis.email}"
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
    service_account_name = "serviceAccount:${google_service_account.sa_order_frontend.email}"
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

