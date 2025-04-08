resource "aws_lambda_function" "processor" {
  function_name = "${var.environment}_data_processor"
  handler       = "main.lambda_handler"
  runtime       = "python3.9"
  role          = module.iam.lambda_role_arn

  s3_bucket = aws_s3_bucket.lambda_code.id
  s3_key    = "lambda/processor.zip"

  environment {
    variables = {
      RAW_BUCKET = aws_s3_bucket.raw.id
    }
  }
}