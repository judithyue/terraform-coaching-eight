# Fetch all available AZs in the current region
data "aws_availability_zones" "available" {
  state = "available"
}