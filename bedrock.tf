
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

# IAM Role for Bedrock Agent with necessary permissions
resource "aws_iam_role" "bedrock_agent_role" {
  name = "bedrock-agent-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Effect    = "Allow",
        Principal = {
          Service = "bedrock.amazonaws.com"
        }
      }
    ]
  })
}

# Attach a policy to give Bedrock Agent permission to use the model and S3
resource "aws_iam_role_policy" "bedrock_agent_policy" {
  name   = "bedrock-agent-policy"
  role   = aws_iam_role.bedrock_agent_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = [
          "bedrock:*",          # Full access to Bedrock API
          "s3:GetObject",       # Access to S3 input
          "s3:PutObject",       # Output writing permission
          "s3:ListBucket",
        ],
        Effect   = "Allow",
        Resource = [
          aws_s3_bucket.bedrock_input_output_bucket.arn,
          "${aws_s3_bucket.bedrock_input_output_bucket.arn}/*"
        ]
      }
    ]
  })
}

# Bedrock Agent creation
resource "aws_bedrock_agent" "bedrock_agent_claude_instant" {
  name                = "my-bedrock-agent-claude-instant"
  model_id            = "anthropic.claude-instant-v1" # This is the model ID for Claude Instant V1
  execution_role_arn  = aws_iam_role.bedrock_agent_role.arn

  # Agent input/output using the newly created S3 bucket
  input_data_config {
    s3_uri = "s3://${aws_s3_bucket.bedrock_input_output_bucket.bucket}/input/prompt.txt"
  }

  output_data_config {
    s3_uri = "s3://${aws_s3_bucket.bedrock_input_output_bucket.bucket}/output/"
  }

#   # Optional - Security Group and VPC Configuration
#   vpc_config {
#     subnet_ids         = ["subnet-xxxxxxxx", "subnet-yyyyyyyy"] # Provide your subnet IDs
#     security_group_ids = ["sg-xxxxxxxx"]                         # Provide your security group IDs
#   }

#   # Optional - Tags for the agent
#   tags = {
#     "Environment" = "Production"
#     "Project"     = "AI-Project"
#   }
}

# Output the Bedrock Agent ARN and the S3 bucket name
output "bedrock_agent_arn" {
  value = aws_bedrock_agent.bedrock_agent_claude_instant.arn
}

output "s3_bucket_name" {
  value = aws_s3_bucket.bedrock_input_output_bucket.bucket
}