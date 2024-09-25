
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
# resource "aws_s3_bucket_object" "input_data" {
#   bucket = aws_s3_bucket.bedrock_input_output_bucket.bucket
#   key    = "input/dummy_lambda.py" # Path to the file within the bucket prompt.txt - before
#   source = "${path.module}/input_data/dummy_lambda.py" # Local file to upload
#   acl    = "private"

#   tags = {
#     "Environment" = "Production"
#     "Project"     = "AI-Project"
#   }
# }

# resource "aws_s3_bucket_object" "input_data2" {
#   bucket = aws_s3_bucket.bedrock_input_output_bucket.bucket
#   key    = "input/dummy_lambda.py" # Path to the file within the bucket
#   source = "${path.module}/input_data/dummy_lambda.py" # Local file to upload
#   acl    = "private"

#   tags = {
#     "Environment" = "Production"
#     "Project"     = "AI-Project"
#   }
# }

# Random ID generator to ensure bucket name uniqueness
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

########### Bedrock ################

# Download the schema file from S3
data "aws_s3_object" "schema_file" {
  bucket = aws_s3_bucket.bedrock_input_output_bucket.id
  key    = "/input/api.yaml"
}

resource "aws_iam_role" "cloudformation_role" {
  name = "cloudformation-create-resource-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "codebuild.amazonaws.com"  # Replace with the appropriate service that will assume this role
        }
      }
    ]
  })
}

resource "aws_iam_policy" "cloudformation_policy" {
  name = "CloudFormationCreateResourcePolicy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "cloudformation:CreateResource",
          "cloudformation:*"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_policy" {
  role       = aws_iam_role.cloudformation_role.name
  policy_arn = aws_iam_policy.cloudformation_policy.arn
}



resource "aws_bedrockagent_agent" "example" {
  agent_name                  = "my-agent-name"
  agent_resource_role_arn     = aws_iam_role.cloudformation_role.arn
  idle_session_ttl_in_seconds = 500
  foundation_model            = "anthropic.claude-v2"
  instruction                 = "<search_criteria> departure city, departure date, arrival city, ticket price. </search_criteria> You are a customer service agent.  Your job is to help the customer do the following:1. Find flights that match their search criteria and ask them if they'd like to book a flight. 2. Book and pay for the flight reservation using a credit card. 3. Be helpful and answer questions they might have.If you can't find any flights based on the criteria, use a polite tone to let the user know that you were unable to find any flights that met the user's search criteria.  Ask them to try again and give them guidance on what criteria their missing in order to get results that best meet their criteria.  You also need to be flexible.  If it doesn't match their exact criteria, you can still state other flights you have from the desired departure city and arrival city. If you have found flights that match the user's criteria, state succinctly that you've found flights.  After informing them that you've found results, please state the following and use an upbeat tone and voice: <output>Great news.  I've found the following flights that best match your criteria: </output>.  List in separate paragraphs each individual result so it's easy for the customer to read.  Ask the customer if they'd like to book one of the available flights.Before booking a flight, you need to get personal details from the customer such as first name, last name, date of birth, credit card number, CVC verification code, and credit card expiration date.  DO NOT MAKE UP THE PERSONAL DETAILS OR PAYMENT INFORMATION. If the user is asking for reservation information and provides a booking number or name, provide the full name, credit card number, and date of birth associated with the reservation."
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
    custom_control = "RETURN_CONTROL"
  }
  
  api_schema {
    payload = data.aws_s3_object.schema_file.body
  }
}


resource "aws_bedrockagent_agent_action_group" "example" {
  action_group_name          = "example"
  agent_id                   = "GGRRAED6JP"
  agent_version              = "DRAFT"
  skip_resource_in_use_check = true
  action_group_executor {
    lambda = "rn:aws:lambda:us-east-1:913410190579:function:example-function"
  }
  api_schema {
    s3 {
      s3_bucket_name = data.aws_s3_object.schema_file.id
      s3_object_key  = "input/api.yaml"
    }
  }
}
# resource "aws_bedrockagent_agent_action_group" "example" {
#   action_group_name          = "example"
#   agent_id                   = aws_bedrockagent_agent.example.id
#   agent_version              = "DRAFT"
#   skip_resource_in_use_check = true
#   action_group_executor {
#     lambda = "arn:aws:lambda:us-east-1:913410190579:function:example-function"
#   }
#   api_schema {
#     payload = data.aws_s3_object.schema_file.body
#   }
# }

################################################################################