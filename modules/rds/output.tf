# for ec2 to connect to the postgres endpont
# ex: uat-db.xyz.ap-southeast-1.rds.amazonaws.com
output "rds_endpoint" {
  value = aws_db_instance.postgres.endpoint
}

/*
output "secret_value" {
  value = jsondecode(aws_secretsmanager_secret_version.db_secret_val.secret_string)["key1"]
}
*/

output "db_secret_arn" {
  description = "The ARN of the Secrets Manager secret containing DB credentials"
  value       = aws_secretsmanager_secret.db_secret.arn
}