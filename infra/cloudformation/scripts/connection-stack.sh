#!/bin/bash
# This script creates the NAT schedule stack in AWS CloudFormation
# It uses default values for bucket name and AWS region if not provided
set -e

# Parameters with default values
bucket_name=${1:-"miracle-implied-cft-template"}
aws_region=${2:-"ap-southeast-1"}
path_to_file=${3:-"connection.yaml"}
stack_name="ConnectionStack"

# Skip if the stack already exists
if aws cloudformation describe-stacks --stack-name "$stack_name" >/dev/null 2>&1; then
  echo "Stack $stack_name already exists. Skipping creation."
  exit 0
fi

aws cloudformation create-stack \
        --stack-name $stack_name \
        --template-url https://$bucket_name.s3.$aws_region.amazonaws.com/$path_to_file \
        --capabilities CAPABILITY_NAMED_IAM

echo "Waiting for $stack_name stack creation to complete..."

./wait-process.sh "$stack_name"

echo "$stack_name stack created successfully."
