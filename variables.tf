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
  default = "amazon.titan-text-premier-v1:0"
}

variable "alternative_foundationmodel" {
  description = "Define Foundation Model"
  default = "anthropic.claude-instant-v1"
}

variable "unique_id" {
  description = "String suffix to apply to resource names that need to be unique"
  type        = string
  default     = "test"
}
