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