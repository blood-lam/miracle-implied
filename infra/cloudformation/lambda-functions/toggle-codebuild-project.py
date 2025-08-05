import os
import boto3

project_name = os.environ["PROJECT_NAME"]

def handler(event, context):
    codebuild = boto3.client('codebuild')
    
    action = event.get("action", "OFF").upper()  # OFF or ON

    if action == "OFF":
        codebuild.update_project(
            name=project_name,
            triggers={
                'webhook': False
            }
        )
        return {"status": "disabled"}

    elif action == "ON":
        codebuild.update_project(
            name=project_name,
            triggers={
                'webhook': True
            }
        )
        return {"status": "enabled"}
    else:
        return {"error": "Invalid action. Use 'ON' or 'OFF'."}
