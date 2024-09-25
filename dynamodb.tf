resource "aws_dynamodb_table" "my_table" {
  name           = var.dynamodb_table_name
  billing_mode   = "PAY_PER_REQUEST"

  hash_key       = "flight_number"  # Primary key (adjust according to your schema)
  
  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Name = "AWSJam"
  }
}



resource "aws_dynamodb_table_item" "example" {
  table_name = aws_dynamodb_table.my_table.name
  hash_key   = aws_dynamodb_table.my_table.hash_key

  item = <<ITEM
{
  "flight_number": {"S": "D835"},
  "departure_city": {"S": "San Diego"},
  "arrival_city": {"S": "Houston"},
  "departure_time": {"S": "2024-11-20 03:10"},
  "flight_details": {"S": "2 Stops"},
  "ticket_price": {"N": "745.04"}
}
ITEM
}

resource "aws_dynamodb_table_item" "flight_data_2" {
  table_name = aws_dynamodb_table.my_table.name
  hash_key   = aws_dynamodb_table.my_table.hash_key

  item = <<ITEM
{
  "flight_number": {"S": "C547"},
  "departure_city": {"S": "Dallas"},
  "arrival_city": {"S": "Charlotte"},
  "departure_time": {"S": "2024-06-11 10:18"},
  "flight_details": {"S": "Non-stop"},
  "ticket_price": {"N": "417.91"}
}
ITEM
}

resource "aws_dynamodb_table_item" "flight_data_3" {
  table_name = aws_dynamodb_table.my_table.name
  hash_key   = aws_dynamodb_table.my_table.hash_key

  item = <<ITEM
{
  "flight_number": {"S": "A160"},
  "departure_city": {"S": "Columbus"},
  "arrival_city": {"S": "Philadelphia"},
  "departure_time": {"S": "2024-02-22 02:20"},
  "flight_details": {"S": "Direct"},
  "ticket_price": {"N": "309.13"}
}
ITEM
}

resource "aws_dynamodb_table_item" "flight_data_4" {
  table_name = aws_dynamodb_table.my_table.name
  hash_key   = aws_dynamodb_table.my_table.hash_key

  item = <<ITEM
{
  "flight_number": {"S": "F546"},
  "departure_city": {"S": "Los Angeles"},
  "arrival_city": {"S": "Chicago"},
  "departure_time": {"S": "2024-05-05 17:30"},
  "flight_details": {"S": "Direct"},
  "ticket_price": {"N": "194.87"}
}
ITEM
}

resource "aws_dynamodb_table_item" "flight_data_5" {
  table_name = aws_dynamodb_table.my_table.name
  hash_key   = aws_dynamodb_table.my_table.hash_key

  item = <<ITEM
{
  "flight_number": {"S": "E331"},
  "departure_city": {"S": "San Antonio"},
  "arrival_city": {"S": "San Diego"},
  "departure_time": {"S": "2024-06-08 08:17"},
  "flight_details": {"S": "1 Stop"},
  "ticket_price": {"N": "865.15"}
}
ITEM
}

resource "aws_dynamodb_table_item" "flight_data_6" {
  table_name = aws_dynamodb_table.my_table.name
  hash_key   = aws_dynamodb_table.my_table.hash_key

  item = <<ITEM
{
  "flight_number": {"S": "Z835"},
  "departure_city": {"S": "San Antonio"},
  "arrival_city": {"S": "Los Angeles"},
  "departure_time": {"S": "2024-09-24 19:17"},
  "flight_details": {"S": "2 Stops"},
  "ticket_price": {"N": "931.6"}
}
ITEM
}

resource "aws_dynamodb_table_item" "flight_data_7" {
  table_name = aws_dynamodb_table.my_table.name
  hash_key   = aws_dynamodb_table.my_table.hash_key

  item = <<ITEM
{
  "flight_number": {"S": "A451"},
  "departure_city": {"S": "San Diego"},
  "arrival_city": {"S": "Austin"},
  "departure_time": {"S": "2024-01-13 10:57"},
  "flight_details": {"S": "1 Stop"},
  "ticket_price": {"N": "622.46"}
}
ITEM
}

resource "aws_dynamodb_table_item" "flight_data_8" {
  table_name = aws_dynamodb_table.my_table.name
  hash_key   = aws_dynamodb_table.my_table.hash_key

  item = <<ITEM
{
  "flight_number": {"S": "A161"},
  "departure_city": {"S": "San Jose"},
  "arrival_city": {"S": "Houston"},
  "departure_time": {"S": "2024-12-22 04:26"},
  "flight_details": {"S": "Direct"},
  "ticket_price": {"N": "0"}
}
ITEM
}