# ============================================================================
# DynamoDB Table for Visitor Counter
# ============================================================================

resource "aws_dynamodb_table" "visitor_counter" {
  name           = "cv-visitor-counter"
  billing_mode   = "PAY_PER_REQUEST" # On-demand pricing
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = merge(
    var.tags,
    {
      Name        = "CV Website Visitor Counter"
      Description = "Stores visitor count for CV website"
    }
  )
}

# Initialize the counter with zero visits
resource "aws_dynamodb_table_item" "visitor_counter_init" {
  table_name = aws_dynamodb_table.visitor_counter.name
  hash_key   = aws_dynamodb_table.visitor_counter.hash_key

  item = jsonencode({
    id = {
      S = "visitor-count"
    }
    visit_count = {
      N = "0"
    }
  })

  # Only create if item doesn't exist
  lifecycle {
    ignore_changes = [item]
  }
}

# ============================================================================
# IAM Role for Lambda Function
# ============================================================================

resource "aws_iam_role" "lambda_visitor_counter" {
  name = "lambda-visitor-counter-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# Attach basic Lambda execution policy
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_visitor_counter.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Custom policy for DynamoDB access
resource "aws_iam_role_policy" "lambda_dynamodb" {
  name = "lambda-dynamodb-access"
  role = aws_iam_role.lambda_visitor_counter.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:UpdateItem",
          "dynamodb:GetItem",
          "dynamodb:PutItem"
        ]
        Resource = aws_dynamodb_table.visitor_counter.arn
      }
    ]
  })
}

# ============================================================================
# Lambda Function
# ============================================================================

# Create ZIP file for Lambda deployment
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda/visitor_counter.py"
  output_path = "${path.module}/lambda/visitor_counter.zip"
}

resource "aws_lambda_function" "visitor_counter" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "cv-visitor-counter"
  role            = aws_iam_role.lambda_visitor_counter.arn
  handler         = "visitor_counter.lambda_handler"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  runtime         = "python3.11"
  timeout         = 10

  environment {
    variables = {
      DYNAMODB_TABLE = aws_dynamodb_table.visitor_counter.name
    }
  }

  tags = merge(
    var.tags,
    {
      Name        = "CV Visitor Counter"
      Description = "Lambda function to track website visitors"
    }
  )
}

# CloudWatch Log Group for Lambda
resource "aws_cloudwatch_log_group" "lambda_visitor_counter" {
  name              = "/aws/lambda/${aws_lambda_function.visitor_counter.function_name}"
  retention_in_days = 7

  tags = var.tags
}

# ============================================================================
# API Gateway HTTP API (More Reliable than Function URL)
# ============================================================================

resource "aws_apigatewayv2_api" "visitor_counter" {
  name          = "cv-visitor-counter-api"
  protocol_type = "HTTP"
  description   = "API for CV website visitor counter"

  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["GET", "POST", "OPTIONS"]
    allow_headers = ["content-type", "x-amz-date", "authorization", "x-api-key", "x-amz-security-token"]
    max_age       = 86400
  }

  tags = var.tags
}

resource "aws_apigatewayv2_stage" "visitor_counter" {
  api_id      = aws_apigatewayv2_api.visitor_counter.id
  name        = "$default"
  auto_deploy = true

  tags = var.tags
}

resource "aws_apigatewayv2_integration" "visitor_counter" {
  api_id           = aws_apigatewayv2_api.visitor_counter.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.visitor_counter.invoke_arn
  
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "visitor_counter_post" {
  api_id    = aws_apigatewayv2_api.visitor_counter.id
  route_key = "POST /count"
  target    = "integrations/${aws_apigatewayv2_integration.visitor_counter.id}"
}

resource "aws_apigatewayv2_route" "visitor_counter_get" {
  api_id    = aws_apigatewayv2_api.visitor_counter.id
  route_key = "GET /count"
  target    = "integrations/${aws_apigatewayv2_integration.visitor_counter.id}"
}

resource "aws_apigatewayv2_route" "visitor_counter_options" {
  api_id    = aws_apigatewayv2_api.visitor_counter.id
  route_key = "OPTIONS /count"
  target    = "integrations/${aws_apigatewayv2_integration.visitor_counter.id}"
}

# Lambda permission for API Gateway
resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.visitor_counter.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.visitor_counter.execution_arn}/*/*"
}

# ============================================================================
# Lambda Function URL (Commented Out - Use API Gateway Instead)
# ============================================================================

# Keeping this commented in case you want to try Function URL again later
# The issue is that Function URLs sometimes have permission evaluation bugs

/*
resource "aws_lambda_function_url" "visitor_counter" {
  function_name      = aws_lambda_function.visitor_counter.function_name
  authorization_type = "NONE"

  cors {
    allow_origins     = ["*"]
    allow_methods     = ["*"]
    allow_headers     = ["content-type"]
    max_age          = 86400
  }
}

resource "aws_lambda_permission" "function_url" {
  statement_id           = "FunctionURLAllowPublicAccess"
  action                 = "lambda:InvokeFunctionUrl"
  function_name          = aws_lambda_function.visitor_counter.function_name
  principal              = "*"
  function_url_auth_type = "NONE"
}
*/

# Alternative: API Gateway (commented out - use if you prefer API Gateway over Function URL)
# Uncomment below if you want to use API Gateway instead of Lambda Function URL

/*
resource "aws_apigatewayv2_api" "visitor_counter" {
  name          = "cv-visitor-counter-api"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["GET", "POST", "OPTIONS"]
    allow_headers = ["content-type"]
    max_age       = 86400
  }

  tags = var.tags
}

resource "aws_apigatewayv2_stage" "visitor_counter" {
  api_id      = aws_apigatewayv2_api.visitor_counter.id
  name        = "$default"
  auto_deploy = true

  tags = var.tags
}

resource "aws_apigatewayv2_integration" "visitor_counter" {
  api_id           = aws_apigatewayv2_api.visitor_counter.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.visitor_counter.invoke_arn
}

resource "aws_apigatewayv2_route" "visitor_counter" {
  api_id    = aws_apigatewayv2_api.visitor_counter.id
  route_key = "GET /count"
  target    = "integrations/${aws_apigatewayv2_integration.visitor_counter.id}"
}

resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.visitor_counter.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.visitor_counter.execution_arn}//*//*"
}
*/
