#export TF_LOG="DEBUG"


#module "gcp" {
#  source            = "./modules"
#  name              = var.name
#  gcp_project       = var.gcp_project
#  region            = var.region
#  zone              = var.zone
#  subnet_cidr_range = var.subnet_cidr_range
#}

#resource "random_string" "random_suffix" {
#  length  = 11
#  special = false
#  upper   = false
#}

resource "random_id" "random_suffix" {
  keepers = {
    first = "${timestamp()}"
  }     
  byte_length = 10
}

#roles/resourcemanager.folderCreator permission is needed
resource "google_folder" "logistics-demo" {
  display_name = "demo-terraform"
  parent       = "organizations/641067203402"
}

#roles/resourcemanager.projectCreator permission is needed
resource "google_project" "terrform_generated_project" {
  name       = "terraform-project"
  project_id = "terraform-project-2965004"
  billing_account = "0144C2-0889E7-23B95D"
  folder_id  = google_folder.logistics-demo.name
}

variable "services" {
  type = list(string)
  default = ["bigtable.googleapis.com","compute.googleapis.com","iam.googleapis.com","run.googleapis.com","cloudbilling.googleapis.com","containerregistry.googleapis.com","dns.googleapis.com","bigquery.googleapis.com","pubsub.googleapis.com"]
}

resource "google_project_service" "enable_api" {
  for_each = toset(var.services)
  project = google_project.terrform_generated_project.project_id
  service = each.value
  disable_on_destroy = true
}

resource "google_compute_network" "vpc_network" {
  project                 = google_project.terrform_generated_project.project_id
  name                    = "terraform-network"
  auto_create_subnetworks = false
  mtu                     = 1460
  depends_on = [google_project_service.enable_api]
}

resource "google_compute_subnetwork" "vpc_subnetwork" {
  name          = "terraform-sub-network"
  ip_cidr_range = "10.0.0.0/24"
  region        = "asia-south1"
  private_ip_google_access = true
  network       = google_compute_network.vpc_network.id
  project       = google_project.terrform_generated_project.project_id
}

resource "google_pubsub_topic" "pubsub_topic" {
  name          = "logistics"
  project       = google_project.terrform_generated_project.project_id
}

resource "google_storage_bucket" "gcs_master_data" {
  name          = google_project.terrform_generated_project.project_id
  location      = "asia-south1"
  force_destroy = true
  project       = google_project.terrform_generated_project.project_id
  public_access_prevention = "enforced"
  uniform_bucket_level_access = true
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
}


resource "google_bigquery_dataset" "dataset" {
  dataset_id    = "logistics"
  friendly_name = "logistics"
  description   = "Terraform Created Dataset"
  location      = "asia-south1"
  project       = google_project.terrform_generated_project.project_id
  depends_on    = [google_project_service.enable_api]
}

resource "google_bigquery_table" "table" {
  dataset_id = google_bigquery_dataset.dataset.dataset_id
  table_id   = "logistics"
  project    = google_project.terrform_generated_project.project_id

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
  }
]
EOF

}

resource "google_bigquery_table" "suppliers_table" {
  dataset_id = google_bigquery_dataset.dataset.dataset_id
  table_id   = "suppliers"
  project    = google_project.terrform_generated_project.project_id
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
  location   = "asia-south1"
  project = google_project.terrform_generated_project.project_id


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
  project    = google_project.terrform_generated_project.project_id
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
  location   = "asia-south1"
  project = google_project.terrform_generated_project.project_id

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
  project    = google_project.terrform_generated_project.project_id
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
  location   = "asia-south1"
  project = google_project.terrform_generated_project.project_id

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
  project    = google_project.terrform_generated_project.project_id
  deletion_protection  = "true"

  cluster {
    cluster_id    = "logistics-cluster"
    num_nodes     = 1
    storage_type  = "HDD"
    zone          = "asia-south1-b"
  }

  lifecycle {
    prevent_destroy = true
  }  

}

resource "google_bigtable_table" "bigtable-table-order" {
  name          = "logistics-order"
  instance_name = google_bigtable_instance.bigtable-instance.name
  project    = google_project.terrform_generated_project.project_id  

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_bigtable_table" "bigtable-table-customer" {
  name          = "logistics-customer"
  instance_name = google_bigtable_instance.bigtable-instance.name
  project    = google_project.terrform_generated_project.project_id  

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_bigtable_app_profile" "bigtable-app-profile" {
  instance        = google_bigtable_instance.bigtable-instance.name
  app_profile_id  = "logistics-app-profile"
  ignore_warnings = true
  project         = google_project.terrform_generated_project.project_id

  single_cluster_routing {
    cluster_id                 = "logistics-cluster"
    allow_transactional_writes = true
  }
}

