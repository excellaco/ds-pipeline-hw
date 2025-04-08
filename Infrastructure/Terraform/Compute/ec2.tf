resource "aws_instance" "data_processor" {
  ami                  = data.aws_ami.ubuntu.id
  instance_type        = "t3.medium"
  iam_instance_profile = module.iam.ec2_instance_profile_name
  subnet_id            = var.subnet_ids[0]

  user_data = templatefile("${path.module}/templates/ec2_init.sh", {
    s3_script_location = "s3://${var.data_lake_arn}/scripts/processor.py"
  })

  tags = {
    Name = "${var.environment}-data-processor"
  }
}