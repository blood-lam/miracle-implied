#!/bin/bash
# This script initializes the environment by creating necessary AWS resources
# It prompts the user to clear existing resources or create new ones
# It uses default values for bucket name and AWS region if not provided
set -e

# Function to delete a stack and wait until it's gone
delete_stack() {
    local stack_name=$1

    # Check if stack exists
    if ! aws cloudformation describe-stacks --stack-name "$stack_name" >/dev/null 2>&1; then
        echo "Stack $stack_name does not exist. Skipping deletion."
        return 0
    fi

    echo "Deleting stack: $stack_name ..."
    if ! aws cloudformation delete-stack --stack-name "$stack_name"; then
        echo "Failed to delete $stack_name"
        return 1
    fi

    echo "Waiting for $stack_name to be deleted..."
    ./wait-process.sh "$stack_name" "false"

    echo "$stack_name deleted."
}

# Function to clear multiple stacks
clear_resources() {
  echo "Clearing existing resources..."

  for stack_name in "${@}"; do
    delete_stack "$stack_name"
  done

  echo "All resources cleared."
  echo "You can now run the script again to create new resources."
}

if [ -n "$1" ]; then
    IFS=',' read -r -a stack_names <<< "$1"
else
    echo "Select an option:"
    echo "  1. Clear existing resources"
    echo "  2. Clear paid resources"
    echo "  3. Specify stack names to clear (comma-separated)"
    read -p "Enter choice [1-3]: " clear_choice
    clear_choice=${clear_choice:-1}

    if [ "$clear_choice" == "1" ]; then
        stack_names=("CodeBuildStack" "ConnectionStack" "NATScheduleStack" "NATGatewayStack" "VPCStack")
    elif [ "$clear_choice" == "2" ]; then
        stack_names=("NATGatewayStack")
    elif [ "$clear_choice" == "3" ]; then
        read -p "Enter stack names to clear (comma-separated): " stack_names_input
        IFS=',' read -r -a stack_names <<< "$stack_names_input"
    else
        echo "Invalid choice. Exiting."
        exit 1
    fi
fi

clear_resources "${stack_names[@]}"
echo "Finished processing stack deletions."
