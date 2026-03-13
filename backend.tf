terraform {
  backend "s3" {
    # These stay empty in the code
    bucket         = ""
    key            = ""
    region         = var.region
    dynamodb_table = ""
    #use_lockfile = true
    encrypt = true
  }
}
# terraform init -backend-config="backend-config/uat.conf" -reconfigure

