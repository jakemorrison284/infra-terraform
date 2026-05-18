# Detailed Logging Configuration

# Enable detailed logging for monitoring post-migration metrics

resource "aws_cloudwatch_log_group" "detailed_logs" {
  name = "/infra-terraform/detailed-logs"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_stream" "log_stream" {
  name           = "log_stream"
  log_group_name = aws_cloudwatch_log_group.detailed_logs.name
}

resource "aws_lambda_function" "example" {
  # Your Lambda function configuration
  environment {
    LOG_GROUP_NAME = aws_cloudwatch_log_group.detailed_logs.name
  }
}