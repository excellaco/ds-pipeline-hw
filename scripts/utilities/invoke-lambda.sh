#!/bin/bash
# Quick test of Lambda function (dev only)
aws lambda invoke \
  --function-name "$(terraform output -raw lambda_function_name)" \
  --payload '{}' \
  response.json