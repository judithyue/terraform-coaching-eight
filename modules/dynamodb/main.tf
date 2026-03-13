resource "aws_dynamodb_table" "book_inventory" {
  name         = "${var.dynamodb_prefix}-ju-bookinventory"
  billing_mode = "PAY_PER_REQUEST"

  # Partition Key
  hash_key = "ISBN"
  # Sort Key
  range_key = "Genre"

  attribute {
    name = "ISBN"
    type = "S" # String
  }

  attribute {
    name = "Genre"
    type = "S" # String
  }

  # merge(base_tags, extra_tags)
  tags = merge(var.tags, {
    Name = "${var.dynamodb_prefix}-ju" # Adds "fluffy-uat-dynamodb-ju" as a searchable tag      
  })
}

resource "aws_dynamodb_table_item" "book_1" {
  table_name = aws_dynamodb_table.book_inventory.name
  hash_key   = aws_dynamodb_table.book_inventory.hash_key
  range_key  = aws_dynamodb_table.book_inventory.range_key

  item = <<ITEM
{
  "ISBN": {"S": "978-0141036144"},
  "Genre": {"S": "Dystopian"},
  "Title": {"S": "1984"},
  "Author": {"S": "George Orwell"},
  "Stock": {"N": "15"}
}
ITEM
}

resource "aws_dynamodb_table_item" "book_2" {
  table_name = aws_dynamodb_table.book_inventory.name
  hash_key   = aws_dynamodb_table.book_inventory.hash_key
  range_key  = aws_dynamodb_table.book_inventory.range_key

  item = <<ITEM
{
  "ISBN": {"S": "978-0747532743"},
  "Genre": {"S": "Fantasy"},
  "Title": {"S": "Harry Potter and the Philosopher's Stone"},
  "Author": {"S": "J.K. Rowling"},
  "Stock": {"N": "22"}
}
ITEM
}