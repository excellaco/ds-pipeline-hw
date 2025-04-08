# Shared assume role policy
data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = [
        "lambda.amazonaws.com",
        "glue.amazonaws.com", 
        "ec2.amazonaws.com"
      ]
    }
  }
}

# Lake Formation service role
resource "aws_iam_role" "lake_formation" {
  name               = "${var.environment}-lake-formation-service-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# Glue service role
resource "aws_iam_role" "glue" {
  name               = "${var.environment}-glue-service-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# Lambda execution role
resource "aws_iam_role" "lambda" {
  name               = "${var.environment}-lambda-exec-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# EC2 instance profile
resource "aws_iam_role" "ec2" {
  name               = "${var.environment}-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_instance_profile" "ec2" {
  name = "${var.environment}-ec2-profile"
  role = aws_iam_role.ec2.name
}