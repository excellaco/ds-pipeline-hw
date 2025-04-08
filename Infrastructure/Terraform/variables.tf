variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Deployment environment (dev/stage/prod)"
  type        = string
  validation {
    condition     = contains(["dev", "stage", "prod"], var.environment)
    error_message = "Invalid environment"
  }
}

variable "data_lake_admins" {
  description = "List of ARNs with Lake Formation admin permissions"
  type        = list(string)
}

variable "data_lake_bucket_arns" {
  type        = list(string)
  description = "ARNs of data lake S3 buckets"
}