resource "google_bigtable_instance" "bigtable-instance" {
  name = "logistics-inst"
  project    = google_project.terraform_generated_project.project_id
  deletion_protection  = "false"
  depends_on = [google_bigquery_table.table]
  cluster {
    cluster_id    = "logistics-cluster"
    num_nodes     = 1
    storage_type  = "HDD"
    zone          = var.zone
  }

  lifecycle {
    prevent_destroy = false
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
    prevent_destroy = false
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
    prevent_destroy = false
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