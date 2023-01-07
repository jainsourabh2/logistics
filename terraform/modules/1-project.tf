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