terraform {
  backend "gcs" {
    bucket      = "terraform-state-still-toolbox-356811"
    prefix      = "terraform"
    credentials = "credentials.json"
  }
}