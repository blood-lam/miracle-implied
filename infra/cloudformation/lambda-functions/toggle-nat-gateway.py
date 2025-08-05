import boto3
import os
import time

cf = boto3.client("cloudformation")

stack_name = os.environ["NAT_GATEWAY_STACK"]
bucket_name = os.environ["BUCKET_NAME"]
path_to_file = os.environ["PATH_TO_FILE"]

def wait_for_stack(stack_name, target_status):
    """Wait until a stack reaches the given status (e.g., CREATE_COMPLETE, DELETE_COMPLETE)."""
    while True:
        try:
            response = cf.describe_stacks(StackName=stack_name)
            status = response["Stacks"][0]["StackStatus"]
            print(f"Current status of {stack_name}: {status}")
            if status == target_status:
                return True
            elif "FAILED" in status or "ROLLBACK" in status:
                raise Exception(f"Stack {stack_name} failed with status {status}")
        except cf.exceptions.ClientError as e:
            if "does not exist" in str(e) and target_status == "DELETE_COMPLETE":
                print(f"Stack {stack_name} successfully deleted.")
                return True
            else:
                raise
        time.sleep(15)


def handler(event, context):
    action = event.get("action", "OFF").upper()
    print(f"NAT Gateway stack toggle request: {action}")

    if action == "ON":
        print(f"Creating/updating NAT Gateway stack: {stack_name}")
        region = boto3.session.Session().region_name
        cf.create_stack(
            StackName=stack_name,
            TemplateURL=f"https://{bucket_name}.s3.{region}.amazonaws.com/{path_to_file}",
            Capabilities=["CAPABILITY_NAMED_IAM"],
        )
        wait_for_stack(stack_name, "CREATE_COMPLETE")
        print("NAT Gateway stack created.")

    elif action == "OFF":
        print(f"Deleting NAT Gateway stack: {stack_name}")
        cf.delete_stack(StackName=stack_name)
        wait_for_stack(stack_name, "DELETE_COMPLETE")
        print("NAT Gateway stack deleted.")

    else:
        print("Invalid action, use 'ON' or 'OFF'.")
