data "aws_caller_identity" "current" {}

data "aws_region" "current" {}


resource "aws_iam_role" "lambda_role" {
  name = "lambda_awsjam_test-${random_string.global_suffix.result}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "lambda_policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "CreateLogGroup"
        Effect = "Allow"
        Action = "logs:CreateLogGroup"
        Resource = "*"
      },
      {
        Sid    = "CreateLogStreamAndPutLogEvents"
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_lambda_permission" "allow_bedrock" {
  statement_id  = "AllowBedrockInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.my_lambda.function_name
  principal     = "bedrock.amazonaws.com"
  
  source_account = data.aws_caller_identity.current.account_id
  source_arn     = aws_bedrockagent_agent.example.agent_arn
}


resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Attach the AmazonDynamoDBReadOnlyAccess policy to the role
resource "aws_iam_role_policy_attachment" "dynamodb_read_only_access" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBReadOnlyAccess"
}

resource "aws_lambda_function" "my_lambda" {
  function_name = "MyLambdaFunction"  # Replace with your desired Lambda function name
  role          = aws_iam_role.lambda_role.arn
  handler       = "dummy_lambda.lambda_handler"  # Adjust based on your handler function
  runtime       = "python3.8"  # Replace with your desired runtime

  filename = "${path.module}/input_data/dummy_lambda.zip"

  source_code_hash = filebase64sha256("${path.module}/input_data/dummy_lambda.zip")

  environment {
    variables = {
      # Add environment variables if needed
    }
  }
}

resource "null_resource" "lambda_zip" {
  provisioner "local-exec" {
    command = "cd input_data && zip ../dummy_lambda.zip dummy_lambda.py"
  }

  depends_on = [null_resource.lambda_clean]
}

resource "null_resource" "lambda_clean" {
  provisioner "local-exec" {
    command = "rm -f ../dummy_lambda.zip"
  }

  triggers = {
    always_run = "${timestamp()}"
  }
}