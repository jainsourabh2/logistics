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