
# Create S3 bucket (optional, for storing fetched data)
resource "aws_s3_bucket" "data_bucket" {
  bucket = "internet-data-storage-bucket"
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Effect": "Allow",
        "Principal": {
          "Service": "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# IAM policy for Lambda to write to S3 and CloudWatch logs
resource "aws_iam_policy" "lambda_exec_policy" {
  name        = "lambda_exec_policy"
  description = "Policy for Lambda to write to S3 and CloudWatch logs"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "logs:*",
          "s3:PutObject",
          "s3:PutObjectAcl"
        ],
        "Resource": [
          "*"
        ]
      }
    ]
  })
}

# Attach the policy to the Lambda IAM role
resource "aws_iam_role_policy_attachment" "lambda_policy_attachment2" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.lambda_exec_policy.arn
}

# Create Lambda function
resource "aws_lambda_function" "fetch_data_function" {
  filename         = "${path.module}/lambda_function/fetch_data.zip"
  function_name    = "fetch_data_lambda"
  role             = aws_iam_role.lambda_exec_role.arn
  handler          = "fetch_data.lambda_handler"
  source_code_hash = filebase64sha256("${path.module}/lambda_function/fetch_data.zip")
  runtime          = "python3.9"
  
  environment {
    variables = {
      S3_BUCKET = aws_s3_bucket.data_bucket.bucket
    }
  }
}

# API Gateway to trigger Lambda
resource "aws_apigatewayv2_api" "http_api" {
  name          = "fetch-data-api"
  protocol_type = "HTTP"
}

# API Gateway Integration with Lambda
resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id           = aws_apigatewayv2_api.http_api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.fetch_data_function.arn
  integration_method = "POST"
}

# API Gateway Route
resource "aws_apigatewayv2_route" "lambda_route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "GET /fetch-data"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

# API Gateway Stage Deployment
resource "aws_apigatewayv2_stage" "default_stage" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "$default"
  auto_deploy = true
}

# Lambda Permission for API Gateway to Invoke
resource "aws_lambda_permission" "api_gateway_invoke" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.fetch_data_function.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*"
}


#outputs
output "api_gateway_url" {
  value = aws_apigatewayv2_api.http_api.api_endpoint
}