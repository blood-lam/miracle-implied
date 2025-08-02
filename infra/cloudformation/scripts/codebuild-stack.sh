#!/bin/bash
# This script creates the CodeBuild stack in AWS CloudFormation
# It uses default values for bucket name and AWS region if not provided
set -e

# Parameters with default values
bucket_name=${1:-"miracle-implied-cft-template"}
aws_region=${2:-"ap-southeast-1"}
path_to_file=${3:-"codebuild.yaml"}
repository=${4:-"https://github.com/blood-lam/miracle-implied"}
stack_name="CodeBuildStack"

aws cloudformation create-stack \
        --stack-name $stack_name \
        --template-url https://$bucket_name.s3.$aws_region.amazonaws.com/$path_to_file \
        --parameters ParameterKey=GitHubRepository,ParameterValue="$repository" \
        --capabilities CAPABILITY_NAMED_IAM

echo "Waiting for $stack_name stack creation to complete..."

./wait-process.sh "$stack_name"

echo "$stack_name stack created successfully."