### GENERAL
variable "region" {
  description = "AWS region used to deploy whole infrastructure"
  type        = string
  default     = "us-east-1"
}

variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table"
  default     = "workshop_flight_data"
}

variable "foundationmodel" {
  description = "Define Foundation Model"
  default = "amazon.titan-text-express-v1"
}
