output "glue_role_arn" {
  value = aws_iam_role.glue.arn
}

output "lambda_role_arn" {
  value = aws_iam_role.lambda.arn
}

output "ec2_instance_profile_name" {
  value = aws_iam_instance_profile.ec2.name
}