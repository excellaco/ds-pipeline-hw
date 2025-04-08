terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    encrypt = true
  }
}

provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      Project     = "data-science-hello-world"
      Environment = var.environment
    }
  }
}

module "data_lake" {
  source = "./modules/data_lake"

  environment       = var.environment
  data_lake_admins = var.data_lake_admins
}

module "compute" {
  source = "./modules/compute"

  environment    = var.environment
  vpc_id        = module.networking.vpc_id
  subnet_ids    = module.networking.private_subnets
  data_lake_arn = module.data_lake.arn
}

module "networking" {
  source = "./modules/networking"

  environment = var.environment
}