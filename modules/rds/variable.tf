variable "rds_prefix" {
  type = string
}

variable "tags" {
  type        = map(string)
  description = "The common_tags from root"
}


variable "private_subnet_ids" {
  type        = list(string) # A list of IDs: ["subnet-1a", "subnet-1b"]
  description = "rds use at lease 2 subnets / thus 2 az"
}

variable "ec2_security_group_id" {
  type = string
  description = "/module/ec2/main.tf (grab the ec2 sgp id"
}

variable "vpc_id" {
  type = string
}