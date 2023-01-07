module "gcp" {
  source          = "./modules"
  region          = var.region
  zone            = var.zone
  organization    = var.organization
  folder          = var.folder
  project         = var.project
  billing-account = var.billing-account
}