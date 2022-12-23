variable "gcp_project" {
  description = "Project Id of the GCP account"
  type        = string
}

variable "region" {
  description = "Region in which the resources will create"
  type        = string
}

variable "zone" {
  description = "Zone in which the resources will create"
  type        = string
}

variable "folder" {
  description = "Folder in which the organization will be created"
  type        = string
}

variable "organization" {
  description = "Organization in which the folder will be created"
  type        = string
}

variable "billing-account" {
  description = "Billing Account to be associated with the project"
  type        = string
}

variable "vpc-network" {
  description = "VPC Network to be created within the project"
  type        = string
}

variable "vpc-sub-network" {
  description = "Subnet to be created within the VPC of the project"
  type        = string
}

variable "vpc-sub-network-ip-cidr" {
  description = "CIDR for the Subnet"
  type        = string
}


