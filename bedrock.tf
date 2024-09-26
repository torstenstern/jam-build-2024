
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
  for_each = fileset("${path.module}/input_data", "*")

  bucket = aws_s3_bucket.bedrock_input_output_bucket.bucket
  key    = "input/${each.value}"
  source = "${path.module}/input_data/${each.value}"
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

# Download the schema file from S3
data "aws_s3_object" "schema_file" {
  bucket = aws_s3_bucket.bedrock_input_output_bucket.id
  key    = "input/api.yaml"

  depends_on = [ aws_s3_bucket_object.input_data ]
}

#IAM Role

# Create the IAM role
resource "aws_iam_role" "bedrock_service_role" {
  name = "bedrock-agent-service-role"

  # Define the trust relationship (assume role policy)
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "bedrock.amazonaws.com"
        }
      }
    ]
  })

  # Add tags if needed
  tags = {
    Environment = "Production"
    Project     = "BedrockAgent"
  }
}

# Create an inline policy for the role with the specified permissions
resource "aws_iam_role_policy" "bedrock_service_role_policy" {
  name = "bedrock-agent-policy"
  role = aws_iam_role.bedrock_service_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AmazonBedrockAgentBedrockFoundationModelPolicyProd"
        Effect = "Allow"
        Action = "bedrock:InvokeModel"
        Resource = [
          "arn:aws:bedrock:${var.region}::foundation-model/${var.foundationmodel}"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "lambda:InvokeFunction"
        ]
        Resource = "*"
      },
      {
        Sid    = "AmazonBedrockAgentCloudWatchPolicyProd"
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}

# Agent 1 Internal Call DynamoDB
# Bedrock Agent
resource "aws_bedrockagent_agent" "example" {
  agent_name                  = "my-agent-name"
  agent_resource_role_arn     = aws_iam_role.bedrock_service_role.arn
  idle_session_ttl_in_seconds = 500
  foundation_model            = var.foundationmodel
  instruction                 = file("${path.module}/input_data/prompt.txt")
  tags = {
    "Environment" = "Production"
    "Project"     = "AI-Project"
  } 
}

# Bedrock Agent Action Group
resource "aws_bedrockagent_agent_action_group" "example" {
  action_group_name          = "example"
  agent_id                   = aws_bedrockagent_agent.example.id
  agent_version              = "DRAFT"
  skip_resource_in_use_check = true
  
   action_group_executor {
    lambda = aws_lambda_function.my_lambda.arn
    }

    api_schema {
      payload = file("input_data/api.yaml")
    }
}


# Agent 2 External Call with API GW
resource "aws_bedrockagent_agent" "external" {
  agent_name                  = "my-agent-name"
  agent_resource_role_arn     = aws_iam_role.bedrock_service_role.arn
  idle_session_ttl_in_seconds = 500
  foundation_model            = var.foundationmodel
  instruction                 = file("${path.module}/input_data/prompt.txt")
  tags = {
    "Environment" = "Production"
    "Project"     = "AI-Project"
  } 
}

# Bedrock Agent Action Group
resource "aws_bedrockagent_agent_action_group" "example" {
  action_group_name          = "external-ag"
  agent_id                   = aws_bedrockagent_agent.etch_data_function.id
  agent_version              = "DRAFT"
  skip_resource_in_use_check = true
  
   action_group_executor {
    lambda = aws_lambda_function.my_lambda.arn
    }

    api_schema {
      payload = file("input_data/api.yaml")
    }
}

################################################################################