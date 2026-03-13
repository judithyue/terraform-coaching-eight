variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = " vpc cidr range to slice"
}

variable "vpc_prefix" {
  type = string
}

# root/main call the module vpc with tags = local.common_tags
# root/main call the modue vpc with prefix = local.prefix
variable "tags" {
  type        = map(string)
  description = "The common_tags from root"
}

/* call from root
module "network" {
  source   = "./modules/vpc"
  vpc_cidr = "10.0.0.0/16"
  
  # Pass the logic from your root/local.tf
  prefix   = local.prefix        # Result: "fluffy-uat"
  tags     = local.common_tags   # Passes Project, Env, CostCenter, etc.
}
*/

# for each , map of objects
variable "subnet_config" {
  type = map(object({
    netnum = number
    public = bool
  }))
  default = {
    "public_1"  = { netnum = 0, public = true }
    "public_2"  = { netnum = 1, public = true }
    "private_1" = { netnum = 3, public = false }
    "private_2" = { netnum = 4, public = false }
  }
}






