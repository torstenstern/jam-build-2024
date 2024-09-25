# resource "aws_dynamodb_table" "my_table" {
#   name           = var.dynamodb_table_name
#   billing_mode   = "PAY_PER_REQUEST"

#   hash_key       = "flight_number"  # Primary key (adjust according to your schema)
  
#   attribute {
#     name = "flight_number"
#     type = "S"
#   }

#   tags = {
#     Name = "AWSJam"
#   }
# }


resource "aws_dynamodb_table" "my_table" {
  name           = "my_table"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "flight_number"
  range_key      = "departure_date"

  attribute {
    name = "flight_number"
    type = "S"
  }

  attribute {
    name = "departure_date"
    type = "S"
  }

  attribute {
    name = "departure_city"
    type = "S"
  }

  attribute {
    name = "arrival_city"
    type = "S"
  }

  global_secondary_index {
    name               = "city-index"
    hash_key           = "departure_city"
    range_key          = "arrival_city"
    projection_type    = "ALL"
  }

  tags = {
    Name        = "my_table"
    Environment = "production"
  }
}


resource "aws_dynamodb_table_item" "flight_data_1" {
  table_name = aws_dynamodb_table.my_table.name
  hash_key   = aws_dynamodb_table.my_table.hash_key
  range_key  = aws_dynamodb_table.my_table.range_key

  item = <<ITEM
{
  "flight_number": {"S": "AA100"},
  "departure_date": {"S": "2024-03-15"},
  "departure_city": {"S": "New York"},
  "arrival_city": {"S": "Los Angeles"},
  "departure_time": {"S": "08:00"},
  "flight_details": {"S": "Non-stop"},
  "ticket_price": {"N": "350.00"}
}
ITEM
}

resource "aws_dynamodb_table_item" "flight_data_2" {
  table_name = aws_dynamodb_table.my_table.name
  hash_key   = aws_dynamodb_table.my_table.hash_key
  range_key  = aws_dynamodb_table.my_table.range_key

  item = <<ITEM
{
  "flight_number": {"S": "UA200"},
  "departure_date": {"S": "2024-03-16"},
  "departure_city": {"S": "Chicago"},
  "arrival_city": {"S": "Miami"},
  "departure_time": {"S": "10:30"},
  "flight_details": {"S": "1 stop"},
  "ticket_price": {"N": "275.50"}
}
ITEM
}

resource "aws_dynamodb_table_item" "flight_data_3" {
  table_name = aws_dynamodb_table.my_table.name
  hash_key   = aws_dynamodb_table.my_table.hash_key
  range_key  = aws_dynamodb_table.my_table.range_key

  item = <<ITEM
{
  "flight_number": {"S": "DL300"},
  "departure_date": {"S": "2024-03-17"},
  "departure_city": {"S": "Atlanta"},
  "arrival_city": {"S": "Denver"},
  "departure_time": {"S": "12:45"},
  "flight_details": {"S": "Non-stop"},
  "ticket_price": {"N": "310.75"}
}
ITEM
}

resource "aws_dynamodb_table_item" "flight_data_4" {
  table_name = aws_dynamodb_table.my_table.name
  hash_key   = aws_dynamodb_table.my_table.hash_key
  range_key  = aws_dynamodb_table.my_table.range_key

  item = <<ITEM
{
  "flight_number": {"S": "SW400"},
  "departure_date": {"S": "2024-03-18"},
  "departure_city": {"S": "Las Vegas"},
  "arrival_city": {"S": "Orlando"},
  "departure_time": {"S": "14:15"},
  "flight_details": {"S": "1 stop"},
  "ticket_price": {"N": "225.00"}
}
ITEM
}

resource "aws_dynamodb_table_item" "flight_data_5" {
  table_name = aws_dynamodb_table.my_table.name
  hash_key   = aws_dynamodb_table.my_table.hash_key
  range_key  = aws_dynamodb_table.my_table.range_key

  item = <<ITEM
{
  "flight_number": {"S": "JB500"},
  "departure_date": {"S": "2024-03-19"},
  "departure_city": {"S": "Boston"},
  "arrival_city": {"S": "San Francisco"},
  "departure_time": {"S": "16:30"},
  "flight_details": {"S": "Non-stop"},
  "ticket_price": {"N": "400.25"}
}
ITEM
}

resource "aws_dynamodb_table_item" "flight_data_6" {
  table_name = aws_dynamodb_table.my_table.name
  hash_key   = aws_dynamodb_table.my_table.hash_key
  range_key  = aws_dynamodb_table.my_table.range_key

  item = <<ITEM
{
  "flight_number": {"S": "AA600"},
  "departure_date": {"S": "2024-03-20"},
  "departure_city": {"S": "Dallas"},
  "arrival_city": {"S": "Seattle"},
  "departure_time": {"S": "09:45"},
  "flight_details": {"S": "1 stop"},
  "ticket_price": {"N": "335.50"}
}
ITEM
}

resource "aws_dynamodb_table_item" "flight_data_7" {
  table_name = aws_dynamodb_table.my_table.name
  hash_key   = aws_dynamodb_table.my_table.hash_key
  range_key  = aws_dynamodb_table.my_table.range_key

  item = <<ITEM
{
  "flight_number": {"S": "UA700"},
  "departure_date": {"S": "2024-03-21"},
  "departure_city": {"S": "Houston"},
  "arrival_city": {"S": "New York"},
  "departure_time": {"S": "11:20"},
  "flight_details": {"S": "Non-stop"},
  "ticket_price": {"N": "290.00"}
}
ITEM
}

resource "aws_dynamodb_table_item" "flight_data_8" {
  table_name = aws_dynamodb_table.my_table.name
  hash_key   = aws_dynamodb_table.my_table.hash_key
  range_key  = aws_dynamodb_table.my_table.range_key

  item = <<ITEM
{
  "flight_number": {"S": "DL800"},
  "departure_date": {"S": "2024-03-22"},
  "departure_city": {"S": "Detroit"},
  "arrival_city": {"S": "Phoenix"},
  "departure_time": {"S": "13:50"},
  "flight_details": {"S": "1 stop"},
  "ticket_price": {"N": "315.75"}
}
ITEM
}

resource "aws_dynamodb_table_item" "flight_data_9" {
  table_name = aws_dynamodb_table.my_table.name
  hash_key   = aws_dynamodb_table.my_table.hash_key
  range_key  = aws_dynamodb_table.my_table.range_key

  item = <<ITEM
{
  "flight_number": {"S": "SW900"},
  "departure_date": {"S": "2024-03-23"},
  "departure_city": {"S": "Chicago"},
  "arrival_city": {"S": "Las Vegas"},
  "departure_time": {"S": "15:30"},
  "flight_details": {"S": "Non-stop"},
  "ticket_price": {"N": "280.50"}
}
ITEM
}

resource "aws_dynamodb_table_item" "flight_data_10" {
  table_name = aws_dynamodb_table.my_table.name
  hash_key   = aws_dynamodb_table.my_table.hash_key
  range_key  = aws_dynamodb_table.my_table.range_key

  item = <<ITEM
{
  "flight_number": {"S": "JB1000"},
  "departure_date": {"S": "2024-03-24"},
  "departure_city": {"S": "San Francisco"},
  "arrival_city": {"S": "Boston"},
  "departure_time": {"S": "18:00"},
  "flight_details": {"S": "1 stop"},
  "ticket_price": {"N": "425.00"}
}
ITEM
}
