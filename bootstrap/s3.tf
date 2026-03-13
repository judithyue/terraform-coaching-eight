provider "aws" {
  region = var.region
}

resource "aws_s3_bucket" "state" {
  # This creates "my-company-tf-state-uat" or "my-company-tf-state-prod"
  bucket = "my-company-tf-state-${var.env_name}-${local.prefix}"

  lifecycle {
    prevent_destroy = false # for actual env is = true
  }
}

resource "aws_dynamodb_table" "locks" {
  name         = "tf-state-lock-${var.env_name}-${local.prefix}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

/*
cd to bootstrap
terraform init
terraform validate
terraform plan -var-file="vars/uat.tfvars"
terraform apply -auto-approve -var-file="vars/uat.tfvars"
*/