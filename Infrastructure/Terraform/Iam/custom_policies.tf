# Lake Formation data access policy
resource "aws_iam_policy" "lake_formation_access" {
  name        = "${var.environment}-lake-formation-access"
  description = "Permissions for Lake Formation data access"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "lakeformation:GetDataAccess",
          "lakeformation:GrantPermissions"
        ],
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}

# Glue S3 and LF access
resource "aws_iam_policy" "glue_data_access" {
  name = "${var.environment}-glue-data-access"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ],
        Effect = "Allow",
        Resource = [
          "arn:aws:s3:::${var.environment}-data-lake-*",
          "arn:aws:s3:::${var.environment}-data-lake-*/*"
        ]
      },
      {
        Action = [
          "lakeformation:GetDataAccess"
        ],
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}

# Lambda data processing policy
resource "aws_iam_policy" "lambda_data_processor" {
  name = "${var.environment}-lambda-data-processor"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "glue:GetTable",
          "glue:GetDatabase"
        ],
        Effect = "Allow",
        Resource = [
          "arn:aws:s3:::${var.environment}-data-lake-*",
          "arn:aws:s3:::${var.environment}-data-lake-*/*",
          "arn:aws:glue:*:*:catalog",
          "arn:aws:glue:*:*:database/${var.environment}_*",
          "arn:aws:glue:*:*:table/${var.environment}_*/*"
        ]
      }
    ]
  })
}

# Attach custom policies
resource "aws_iam_role_policy_attachment" "glue_data_access" {
  role       = aws_iam_role.glue.name
  policy_arn = aws_iam_policy.glue_data_access.arn
}

resource "aws_iam_role_policy_attachment" "lambda_data_processor" {
  role       = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.lambda_data_processor.arn
}