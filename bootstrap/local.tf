#"${local.prefix}-ec2" , local is something you don't want to change unlike var , you can overwrite via x.tfvars
locals {
  prefix = "ju"
}

locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.env_name
    ManagedBy   = "Terraform"
    CostCenter  = var.env_name == "prod" ? "FIN-100" : "DEV-200"
  }
}

