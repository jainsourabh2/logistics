terraform {
  backend "gcs" {
    bucket      = "customer-demos-asia-south1"
    prefix      = "terraform"
  }
}