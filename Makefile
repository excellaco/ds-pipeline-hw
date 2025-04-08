# Makefile for Data Science Hello World Project

# Configuration
ENVIRONMENT ?= dev
AWS_REGION ?= us-east-1
TF_STATE_BUCKET ?= ds-tf-state-bucket
TF_STATE_KEY ?= data-science/$(ENVIRONMENT)/terraform.tfstate

.PHONY: help
help:  ## Display this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n\nTargets:\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)

## -- Infrastructure Management --
init:  ## Initialize Terraform backend
	@echo "Initializing Terraform..."
	@cd infra && terraform init \
		-backend-config="bucket=$(TF_STATE_BUCKET)" \
		-backend-config="key=$(TF_STATE_KEY)" \
		-backend-config="region=$(AWS_REGION)"

plan: init  ## Generate Terraform execution plan
	@cd infra && terraform plan \
		-var="environment=$(ENVIRONMENT)" \
		-var="aws_region=$(AWS_REGION)" \
		-out=tfplan

apply: init  ## Apply Terraform changes
	@cd infra && terraform apply \
		-var="environment=$(ENVIRONMENT)" \
		-var="aws_region=$(AWS_REGION)" \
		-auto-approve

destroy:  ## Destroy infrastructure
	@cd infra && terraform destroy \
		-var="environment=$(ENVIRONMENT)" \
		-var="aws_region=$(AWS_REGION)" \
		-auto-approve

## -- Lambda Functions --
package-lambda:  ## Package Lambda function code
	@echo "Packaging Lambda function..."
	@cd src/lambda/hello_world && \
		zip -r ../hello_world.zip . && \
		cd ../../.. && \
		mv src/lambda/hello_world.zip .

## -- Data Processing --
generate-test-data:  ## Generate sample test data
	@echo "Generating test data..."
	@python scripts/generate_test_data.py

## -- Validation & Testing --
test:  ## Run unit tests
	@pytest tests/unit/ -v

security-check:  ## Run security scans
	@echo "Running security checks..."
	@bandit -r src/
	@safety check -r requirements.txt
	@checkov -d infra/

validate-terraform:  ## Validate Terraform config
	@cd infra && terraform validate

## -- Utility Commands --
clean:  ## Clean build artifacts
	@rm -f src/lambda/*.zip
	@rm -f *.zip
	@find . -name "*.pyc" -delete
	@find . -name "__pycache__" -delete

configure-aws:  ## Configure AWS CLI profile
	@aws configure --profile ds-hello-world

list-outputs:  ## List Terraform outputs
	@cd infra && terraform output

## -- CI/CD Shortcuts --
ci-full: validate-terraform security-check test package-lambda plan  ## CI pipeline steps