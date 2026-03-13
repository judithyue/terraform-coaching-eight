/*

variable "instance_name" { type = string }
variable "ami_id"        { type = string }
variable "instance_type" { type = string; default = "t3.micro" }
variable "subnet_id"     { type = string }
variable "iam_instance_profile" { type = string } # <--- This is the link


*/

variable "sgp_prefix" {
  type = string
}

variable "tags" {
  type        = map(string)
  description = "The common_tags handed over from root"
}

variable "ec2_count" {
  type        = number
  description = "define the number of ec2 to provisioned"
}

variable "instance_type" {
  type = string
}

variable "vpc_id" {
  type = string
}

/*
variable "subnet_id" {
  type = string
}
*/
variable "public_subnet_ids" {
  type = list(string) # A list of IDs: ["subnet-1a", "subnet-1b"]
}


variable "iam_instance_profile_name" {
  type        = string
  description = "pass in ec2 instance profile from root call from iam module "
}
  