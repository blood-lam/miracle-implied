# CloudFormation Deployment Instructions

## Upload CloudFormation Template to S3

To upload your CloudFormation template to an S3 bucket, follow these steps:

1. **Upload the template file to S3**  
    Use the AWS CLI to upload your template file to your S3 bucket:

    ```sh
    aws s3 cp <local-template-file.yaml> s3://<bucket-name>/<template-file.yaml>
    ```

2. **Deploy the CloudFormation stack**  
    Run the following command in CloudShell, replacing the placeholders as needed:

    To create stack:

    ```sh
    aws cloudformation create-stack \
        --stack-name [your-stack-name] \
        --template-url <https://s3.amazonaws.com/[bucket-name]/[template-file.yaml>] \
        --capabilities CAPABILITY_NAMED_IAM
    ```

    Create VPC stack:

    ```sh
    aws cloudformation create-stack \
        --stack-name VPCStack \
        --template-url https://[bucket-name].s3.ap-southeast-1.amazonaws.com/[path-to-file.yaml] \
        --capabilities CAPABILITY_NAMED_IAM
    ```

    Create NAT Schedule stack:

    ```sh
    aws cloudformation create-stack \
        --stack-name NATScheduleStack \
        --template-url https://[bucket-name].s3.ap-southeast-1.amazonaws.com/[path-to-file.yaml] \
        --capabilities CAPABILITY_NAMED_IAM
    ```

3. **Monitor the deployment**  
    Check the CloudFormation console or use the CLI to monitor stack creation and review any outputs or errors.
