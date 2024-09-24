resource "aws_dynamodb_table" "my_table" {
  name           = var.dynamodb_table_name
  billing_mode   = "PAY_PER_REQUEST"

  hash_key       = "id"  # Primary key (adjust according to your schema)
  
  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Name = "AWSJam"
  }
}