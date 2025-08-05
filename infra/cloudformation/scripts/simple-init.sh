#!/bin/bash
# This script initializes the environment by creating necessary AWS resources
# It prompts the user to clear existing resources or create new ones
# It uses default values for bucket name and AWS region if not provided
set -e

read -p "Do you want to clear existing resources? (y/n) [default: n]: " clear_resources
clear_resources=${clear_resources:-n}

if [ "$clear_resources" = "y" ]; then
    ./clear.sh
else
    echo "Starting resource creation..."
    if [ -n "$1" ]; then
        bucket_name=$1
    else
        read -p "Enter your bucket name [default: miracle-implied-cft-template]: " bucket_name
        bucket_name=${bucket_name:-"miracle-implied-cft-template"}
    fi

    if [ -n "$2" ]; then
        aws_region=$2
    else
        read -p "Enter your AWS region [default: ap-southeast-1]: " aws_region
        aws_region=${aws_region:-"ap-southeast-1"}
    fi

    ./vpc-stack.sh "$bucket_name" "$aws_region"
    ./nat-gateway-stack.sh "$bucket_name" "$aws_region" # Safe to delete (for a fee)
    ./nat-schedule.sh "$bucket_name" "$aws_region"
    ./connection-stack.sh "$bucket_name" "$aws_region"
    echo "All resources created successfully."
    echo "You can now proceed with your AWS operations."
fi