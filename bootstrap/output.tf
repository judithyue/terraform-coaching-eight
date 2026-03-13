output "state_bucket_name" {
  value       = aws_s3_bucket.state.id
  description = "The name of the S3 bucket for the remote state"
}

output "dynamodb_table_name" {
  value       = aws_dynamodb_table.locks.name
  description = "The name of the DynamoDB table for state locking"
}

output "aws_region" {
  value       = "ap-southeast-1"
  description = "The region where the backend is located"
}