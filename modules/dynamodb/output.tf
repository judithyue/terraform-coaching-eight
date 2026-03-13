output "dynamodb_arn" {
  value = aws_dynamodb_table.book_inventory.arn

}


output "dynamodb_table_name" {
  value = aws_dynamodb_table.book_inventory.name

}