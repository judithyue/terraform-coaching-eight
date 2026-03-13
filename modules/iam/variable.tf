variable "iam_prefix" {
  type = string
}

variable "tags" {
  type        = map(string)
  description = "The common_tags handed over from root"
}


variable "dynamodb_arn" {
  type        = string
  description = "pass in from the root via module.rds"
}

#---- rds

variable "db_secret_arn" {
  type        = string
  description = "pass in from root via module.rds | The ARN of the rds postgres secret manager to allow the EC2 to read"
}