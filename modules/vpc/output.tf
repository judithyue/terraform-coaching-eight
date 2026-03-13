# 1. Output JUST the Public Subnet IDs as a list
output "public_subnet_ids" {
  description = "List of IDs for public subnets"
  value       = [for k, v in aws_subnet.managed_subnets : v.id if var.subnet_config[k].public == true]
}

# 2. Output JUST the Private Subnet IDs as a list
output "private_subnet_ids" {
  description = "List of IDs for private subnets"
  value       = [for k, v in aws_subnet.managed_subnets : v.id if var.subnet_config[k].public == false]
}

# 3. Output a Map showing which AZ each subnet landed in
output "subnet_az_map" {
  description = "Mapping of subnet names to their assigned Availability Zones"
  value = {
    for k, v in aws_subnet.managed_subnets : k => v.availability_zone
  }
}

/*
vpc_az_map = {
  "private_1" = "ap-southeast-1a"    <--- each zone map to whhich subnet , improve that later
  "private_2" = "ap-southeast-1b"
  "public_1" = "ap-southeast-1a"
  "public_2" = "ap-southeast-1b"
}
*/


output "vpc_id" {
  description = "vpc id"
  value       = aws_vpc.main.id
}