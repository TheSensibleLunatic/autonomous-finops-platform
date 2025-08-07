# terraform/main.tf

provider "aws" {
  region = "us-east-1" # Specify your desired region
}

resource "aws_iam_role" "lambda_exec_role" {
  name = "finops-lambda-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "ec2_rds_stop_policy" {
  name = "EC2_RDS_Stop_Policy"
  role = aws_iam_role.lambda_exec_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = [
        "ec2:DescribeInstances",
        "ec2:StopInstances",
        "rds:DescribeDBInstances",
        "rds:StopDBInstance"
      ]
      Resource = "*"
    }]
  })
}

resource "aws_lambda_function" "finops_lambda" {
  filename      = "../src/lambda_function.zip" # Assumes you zip the python file
  function_name = "autonomous-finops-hibernation"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"
  timeout       = 60
}

resource "aws_cloudwatch_event_rule" "shutdown_rule" {
  name                = "daily-shutdown-rule"
  description         = "Triggers Lambda to shut down dev resources every evening"
  schedule_expression = "cron(0 18 ? * MON-FRI *)" # Every weekday at 6 PM UTC
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule = aws_cloudwatch_event_rule.shutdown_rule.name
  arn  = aws_lambda_function.finops_lambda.arn
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.finops_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.shutdown_rule.arn
}
