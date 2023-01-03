module "gcp" {
  source        	= "./modules"
  project 			= var.project
  folder			= var.folder
  region        	= var.region
  zone          	= var.zone
  organization		= var.organization
  billing-account 	= var.billing-account
}


project			= "on-prem-project-337210"
region			= "asia-south1"
zone			= "asia-south1-a"
folder			= "logistics-demo"
organization	= "641067203402"
billing-account	= "0144C2-0889E7-23B95D"