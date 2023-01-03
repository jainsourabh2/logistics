module "gcp" {
  source        	= "./modules"
  project 			= var.project
  folder			= var.folder
  region        	= var.region
  zone          	= var.zone
  organization		= var.organization
  billing-account 	= var.billing-account
}