variable "region" {
  description = "Region in which the resources will create"
  type        = string
}

variable "zone" {
  description = "Zone in which the resources will create"
  type        = string
}

variable "organization" {
  description = "Organization in which the folder will be created"
  type        = string
}

variable "folder" {
  description = "Folder in which the project will be created"
  type        = string
}

variable "project" {
  description = "Project Id of the GCP account"
  type        = string
}

variable "billing-account" {
  description = "Billing Account to be associated with the project"
  type        = string
}