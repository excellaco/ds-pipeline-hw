resource "aws_athena_workgroup" "analysis" {
  name = "${var.environment}_analysis"

  configuration {
    result_configuration {
      output_location = "s3://${aws_s3_bucket.query_results.id}/"

      encryption_configuration {
        encryption_option = "SSE_S3"
      }
    }
  }
}