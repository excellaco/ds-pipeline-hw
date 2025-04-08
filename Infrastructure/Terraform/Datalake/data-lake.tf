# Lake Formation admin setup
resource "aws_lakeformation_data_lake_settings" "main" {
  admins = [var.data_lake_admin_arn]
}

# Grant permissions to Glue service role
resource "aws_lakeformation_permissions" "glue_access" {
  principal = aws_iam_role.glue_service.arn
  permissions = ["CREATE_TABLE", "ALTER", "DROP"]

  data_location {
    arn = aws_s3_bucket.raw_data.arn
  }
}