#!/bin/bash
# This script initializes the environment by creating necessary AWS resources
# It prompts the user to clear existing resources or create new ones
# It uses default values for bucket name and AWS region if not provided
set -e

read -p "Do you want to clear existing resources? (y/n) [default: n]: " clear_resources
clear_resources=${clear_resources:-n}

# Function to delete a stack and wait until it's gone
delete_stack() {
  local stack_name=$1

  # Check if stack exists
  if ! aws cloudformation describe-stacks --stack-name "$stack_name" >/dev/null 2>&1; then
    echo "Stack $stack_name does not exist. Skipping deletion."
    return 0
  fi

  echo "Deleting stack: $stack_name ..."
  aws cloudformation delete-stack --stack-name "$stack_name"

  echo "Waiting for $stack_name to be deleted..."
  ./wait-process.sh "$stack_name" "false"

  echo "$stack_name deleted."
}

clear_resources() {
  echo "Clearing existing resources..."

  delete_stack "ConnectionStack"
  delete_stack "NATScheduleStack"
  delete_stack "VPCStack"

  echo "All resources cleared."
  echo "You can now run the script again to create new resources."
}

if [ "$clear_resources" = "y" ]; then
    clear_resources
else
    echo "Starting resource creation..."
    if [ -n "$1" ]; then
    bucket_name=$1
    else
        read -p "Enter your bucket name [default: miracle-implied-cft-template]: " bucket_name
        bucket_name=${bucket_name:-miracle-implied-cft-template}
    fi

    if [ -n "$2" ]; then
        aws_region=$2
    else
        read -p "Enter your AWS region [default: ap-southeast-1]: " aws_region
        aws_region=${aws_region:-ap-southeast-1}
    fi

    ./vpc-stack.sh "$bucket_name" "$aws_region"
    ./nat-schedule.sh "$bucket_name" "$aws_region"
    ./connection-stack.sh "$bucket_name" "$aws_region"
    echo "All resources created successfully."
    echo "You can now proceed with your AWS operations."
fi