
variable "tags" {
  type        = map(string)
  description = "The common_tags handed over from root"
}
variable "dynamodb_prefix" {
  type = string
}