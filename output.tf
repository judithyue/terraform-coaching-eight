# Output Public Subnet IDs from the VPC module
output "vpc_public_subnets" {
  description = "List of Public Subnet IDs"
  value       = module.network.public_subnet_ids
}

# Output Private Subnet IDs from the VPC module
output "vpc_private_subnets" {
  description = "List of Private Subnet IDs"
  value       = module.network.private_subnet_ids
}

# Output the AZ Mapping
output "vpc_az_map" {
  description = "Which subnets are in which AZs"
  value       = module.network.subnet_az_map
}

# Output EC2 Public IPs (assuming you have an output in the ec2 module)
output "ec2_public_ips" {
  description = "Public IPs of the app servers"
  value       = module.compute.instance_public_ips
}

# output vpc-id
output "vpc_id" {
  description = "Public IPs of the app servers"
  value       = module.network.vpc_id #output define in the module vpc
}

output "app_public_ips" {
  value = module.compute.instance_public_ips
}

/*
output "app_private_ips" {
  value = module.compute.instance_private_ips
}
*/

output "ec2_instance_profile_name" {
  value       = module.iam_baseline.ec2_instance_profile_name #output define in the module iam
  description = "ec2 instance profile created in module iam"
}

output "dynamodb_table_name" {
  value = module.dynamodb.dynamodb_table_name
}

/*
output "rds_secret_value" {
  value = module.rds.secret_value
  sensitive = true
}
*/