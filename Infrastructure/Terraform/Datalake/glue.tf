resource "aws_glue_catalog_database" "raw" {
  name        = "${var.environment}_raw_db"
  description = "Raw data zone"

  location_uri = "s3://${aws_s3_bucket.raw.id}"
}

resource "aws_glue_job" "etl" {
  name         = "${var.environment}_data_processing"
  role_arn     = module.iam.glue_role_arn
  glue_version = "4.0"

  command {
    script_location = "s3://${aws_s3_bucket.scripts.id}/glue/etl.py"
    python_version  = "3"
  }

  default_arguments = {
    "--enable-continuous-cloudwatch-log" = "true"
    "--enable-lake-formation"            = "true"
  }
}