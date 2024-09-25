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
# variable "s3_bucket" {
#   description = "AWS region used to deploy whole infrastructure"
#   type        = string
# }
# variable "name_prefix" {
#   description = "Prefix used in names for the resources (VPCs, EC2 instances, autoscaling groups etc.)"
#   type        = string
# }
# variable "global_tags" {
#   description = "Global tags configured for all provisioned resources"
# }
