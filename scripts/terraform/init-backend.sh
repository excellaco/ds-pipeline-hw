#!/bin/bash
# Initialize Terraform S3 backend (run once)
terraform init \
  -backend-config="bucket=ds-tf-state-bucket" \
  -backend-config="key=data-science-hello-world/terraform.tfstate" \
  -backend-config="region=us-east-1"