#!/bin/bash
set -e

ENV=${1:-dev}
TF_DIR="infra"

# Initialize and apply Terraform
terraform -chdir=$TF_DIR init \
  -backend-config="bucket=ds-tf-state-$ENV" \
  -backend-config="key=data-lake/$ENV.tfstate"

terraform -chdir=$TF_DIR apply -auto-approve \
  -var="environment=$ENV"

# Post-deploy Lake Formation registration
./scripts/lf_register.sh $ENV