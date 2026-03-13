module "iam_baseline" {
  source       = "./modules/iam"
  tags         = local.common_tags
  iam_prefix   = local.prefix #name of the iam resources
  dynamodb_arn = module.dynamodb.dynamodb_arn
  db_secret_arn = module.rds.db_secret_arn
}

module "network" {
  source     = "./modules/vpc"
  tags       = local.common_tags
  vpc_prefix = local.prefix #name the iam resources
}

module "compute" {
  source    = "./modules/ec2"
  ec2_count = 2
  vpc_id    = module.network.vpc_id

  # This automatically sends all public IDs as a list
  public_subnet_ids         = module.network.public_subnet_ids  # modules/vpc/output.tf 
  iam_instance_profile_name = module.iam_baseline.ec2_instance_profile_name #This is the 'Baton Pass'
  sgp_prefix                = local.prefix
  tags                      = local.common_tags
  instance_type             = "t3.micro"
}

module "dynamodb" {
  source          = "./modules/dynamodb"
  tags            = local.common_tags
  dynamodb_prefix = local.prefix
}

module rds {
   source          = "./modules/rds"
   tags = local.common_tags
   rds_prefix = local.prefix
   vpc_id = module.network.vpc_id
   private_subnet_ids = module.network.public_subnet_ids
   ec2_security_group_id = module.compute.ec2_sgp
}