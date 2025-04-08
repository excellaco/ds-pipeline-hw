output "glue_job_name" {
  value       = module.data_lake.glue_job_name
  description = "Name of the created Glue ETL job"
}

output "lambda_function_arn" {
  value       = module.compute.lambda_arn
  description = "ARN of the data processor Lambda"
}

output "ec2_instance_ip" {
  value       = module.compute.ec2_private_ip
  description = "Private IP of the EC2 instance"
}

output "glue_role_arn" {
  value = aws_iam_role.glue.arn
}

output "lambda_role_arn" {
  value = aws_iam_role.lambda.arn
}

output "ec2_instance_profile_name" {
  value = aws_iam_instance_profile.ec2.name
}