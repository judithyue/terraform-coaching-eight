variable "project_name" {
  type        = string
  description = "project name"
}

variable "env_name" {
  type        = string
  description = "The environment name (uat or prod)"
}

variable "region" {
  type    = string
  default = "ap-southeast-1"
}
