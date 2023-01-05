---
sidebar_position: 1
---

# Installation Steps

## For Argolis Users:

1) Log in via the admin user on GCP Argolis console.
2) Open the cloud shell via the GCP console.
3) Clone the repository by running the below command :

    git clone https://github.com/jainsourabh2/logistics.git 

4) Navigate into logistics/terraform directory

    cd logistics/terraform

5) Open the terraform.tfvars file and change the values appropriately.

    project                 = "unique_project_name"
    region                  = "region"
    zone                    = "zone"
    folder                  = "logistics-demo"
    organization            = "12 digit ord id"
    billing-account         = "XXXXXX-YYYYYY-ZZZZZZ" 

6) Open the backend.tf file and change the bucket value to an exisitng bucket from the current logged in project.

    terraform {
      backend "gcs" {
        bucket      = "replace_this_with_bucket_name"
        prefix      = "terraform"
      }

7) Run the below command to initialize terraform.

    terraform init

8) Run the below command to validate the structure of terraform 

    terraform validate

9) Run the below command to apply changes in your project.

    terraform apply.

  Once you run the above command, you would be asked for confirmation. Please provide "yes"

10) Post the deployment , provide the permissions to allow unauthenticated access to the Cloud Run 3 services. 

**NOTE : In Arglois, by default org policy blocks unauthenticated access and hence the policy(constraints/iam.allowedPolicyMemberDomains) needs to be allowed and then unauthenticated access needs to be enabled on the cloud run URLs**

If you pface any errors , please contact xyz@google.com hello

## For General Users:

1) Log in via the admin user on GCP Argolis console.
2) Open the cloud shell via the GCP console.
3) Clone the repository by running the below command :

    git clone https://github.com/jainsourabh2/logistics.git 

4) Navigate into logistics/terraform directory

    cd logistics/terraform

5) Open the terraform.tfvars file and change the values appropriately.

    project                 = "unique_project_name"
    region                  = "region"
    zone                    = "zone"
    folder                  = "logistics-demo"
    organization            = "12 digit ord id"
    billing-account         = "XXXXXX-YYYYYY-ZZZZZZ" 

6) Open the backend.tf file and change the bucket value to an exisitng bucket from the current logged in project.

    terraform {
      backend "gcs" {
        bucket      = "replace_this_with_bucket_name"
        prefix      = "terraform"
      }

7) Run the below command to initialize terraform.

    terraform init

8) Run the below command to validate the structure of terraform 

    terraform validate

9) Run the below command to apply changes in your project.

    terraform apply.

  Once you run the above command, you would be asked for confirmation. Please provide "yes"
