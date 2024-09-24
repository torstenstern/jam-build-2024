
# S3 Bucket for storing input/output data
resource "aws_s3_bucket" "bedrock_input_output_bucket" {
  bucket = "bedrock-agent-input-output-${random_id.bucket_suffix.hex}" # Unique bucket name

  # Enable versioning for the S3 bucket (optional)
  versioning {
    enabled = true
  }

  tags = {
    "Environment" = "Production"
    "Project"     = "AI-Project"
  }
}

# Upload input_data file to the S3 bucket
resource "aws_s3_bucket_object" "input_data" {
  bucket = aws_s3_bucket.bedrock_input_output_bucket.bucket
  key    = "input/prompt.txt" # Path to the file within the bucket
  source = "${path.module}/input_data/prompt.txt" # Local file to upload
  acl    = "private"

  tags = {
    "Environment" = "Production"
    "Project"     = "AI-Project"
  }
}

# Random ID generator to ensure bucket name uniqueness
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

########### Bedrock ################

resource "aws_iam_role" "service_role" {
  name = "my_service_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"  # Change this to the service you want to use (e.g., ec2.amazonaws.com)
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name        = "my-service-role"
    Environment = "production"
  }
}



resource "awscc_bedrock_agent" "example" {
  agent_name              = "example-agent"
  description             = "Example agent configuration"
  agent_resource_role_arn = aws_iam_role.service_role.id
  foundation_model        = "anthropic.claude-v2:1"
  instruction             = "You are an office assistant in an insurance agency. You are friendly and polite. You help with managing insurance claims and coordinating pending paperwork."
  knowledge_bases = [{
    description          = "example knowledge base"
    # knowledge_base_id    = var.knowledge_base_id
    knowledge_base_state = "ENABLED"
  }]

  # customer_encryption_key_arn = var.kms_key_arn
  idle_session_ttl_in_seconds = 600
  auto_prepare                = true

  # action_groups = [{
  #   action_group_name = "example-action-group"
  #   description       = "Example action group"
  #   api_schema = {
  #     s3 = {
  #       s3_bucket_name = var.bucket_name
  #       s3_object_key  = var.bucket_object_key
  #     }
    # }
    # action_group_executor = {
    #   lambda = var.lambda_arn
    # }

  # }]

  tags = {
    "Modified By" = "AWSCC"
  }

}
################################################################################