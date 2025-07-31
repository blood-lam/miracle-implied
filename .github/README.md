# To create an AWS CodeBuild project and connect it to GitHub Actions

1. **Create a CodeBuild Project:**
    - Go to the AWS Management Console.
    - Navigate to **CodeBuild**
    - Go to Settings > Connections
        - Create a connection to GitHub
    - click **Create build project**.
    - Fill in the project details (name, description, environment, etc.).
    - Under **Source provider**, select **GitHub** and connect your GitHub repository.
    - Configure the buildspec file or use the default settings.
    - Set up environment variables and IAM roles as needed.
    - Click **Create build project**.

2. **Connect to GitHub Actions:**
    - In your GitHub repository, create a workflow YAML file under `.github/workflows/`.
    - Use the [aws-actions/aws-codebuild-run-build](https://github.com/aws-actions/aws-codebuild-run-build) action to trigger CodeBuild from GitHub Actions.
    - Example workflow step:

      ```yaml
      - name: Trigger AWS CodeBuild
        uses: aws-actions/aws-codebuild-run-build@v1
        with:
          project-name: <your-codebuild-project-name>
      ```

    - Ensure your GitHub repository has the necessary AWS credentials set as secrets.

This setup allows you to trigger AWS CodeBuild builds directly from your GitHub Actions workflows.
