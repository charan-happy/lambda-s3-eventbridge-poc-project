## Project Overview
This project uses Terraform to deploy a serverless, multi-region application on AWS. It demonstrates how to centralize Lambda function code in a single Amazon S3 bucket in one region (us-west-1), and then deploy that code to Lambda functions in other regions (ap-south-1 and ap-southeast-1). The functions in each region are triggered by an EventBridge Cron Scheduler and write logs to their respective CloudWatch Log Groups.

## Architecture
The architecture consists of the following components:

Central S3 Bucket (us-west-1): Stores the Lambda function code package (lambda_code.zip) in a central location. This acts as the single source of truth for the application code.

Regional S3 Buckets (ap-south-1, ap-southeast-1): These buckets are created in each target region and are used to stage the Lambda code. Note: AWS Lambda requires the function code to be sourced from an S3 bucket in the same region. Terraform handles the replication of the code from the central bucket to these regional buckets.

IAM Role: A single IAM role with the necessary permissions to allow the Lambda function to execute, write logs to CloudWatch, and read the code from the regional S3 bucket.

Lambda Functions (ap-south-1, ap-southeast-1): The core application logic. The functions are configured to use the code from their regional S3 bucket.

EventBridge Cron Schedulers (ap-south-1, ap-southeast-1): Triggers each Lambda function every 5 minutes using a rate(5 minutes) expression.

CloudWatch Log Groups: Automatically created for each Lambda function to store the execution logs. The logs are visible in the respective region's CloudWatch console.

## Prerequisites
Before you can deploy this project, ensure you have the following installed and configured:

Terraform CLI: Version 1.0 or later.

AWS CLI: Configure your AWS credentials with a user or role that has permissions to create S3 buckets, IAM roles, Lambda functions, and EventBridge rules. You can do this by running aws configure.

Lambda Code Package: A lambda_code.zip file containing your Node.js code (index.js with the exports.handler function).

## Deployment
Follow these steps to deploy the infrastructure using Terraform:

Clone the Repository:
```
git clone <your-repository-url>
cd <your-repository-directory>
```

2. Update Variables:
Open the variables.tf file and update the central_s3_bucket_name to a unique, globally available name.
```
variable "central_s3_bucket_name" {
  description = "The name for the central S3 bucket in us-west-1."
  type        = string
  default     = "your-unique-lambda-code-bucket-name"
}
```
3. Initialize Terraform:
This command will download the necessary provider plugins.
```
terraform init
```

Review the Plan:
Run terraform plan to see the resources that will be created. Review the output carefully to ensure it matches your expectations.

`terraform plan`
Apply the Configuration:
If the plan is acceptable, apply the changes to create the resources in your AWS account.
`terraform apply --auto-approve`

## Monitoring and Verification
Once the deployment is complete, you can verify that everything is working as expected:

Check CloudWatch Logs:

Navigate to the CloudWatch console in the Mumbai (ap-south-1) and Singapore (ap-southeast-1) regions.

In the navigation pane, select Log groups.

You should see log groups for your Lambda functions (/aws/lambda/HelloWorldFunction-Mumbai and /aws/lambda/HelloWorldFunction-Singapore).

Click on a log group and then a log stream to see the "Hello from a Lambda function!" message, confirming successful execution.

## Cleanup
To avoid incurring unexpected AWS costs, it is important to destroy all the resources when you no longer need them.

Run terraform destroy
`terraform destroy`

This will remove all S3 buckets, IAM roles, Lambda functions, and EventBridge rules created by your Terraform code.

## High-level execution

Here's how it works at a high level:

IAM Role and Policy: The code first creates a single IAM role and attaches a policy that gives the Lambda functions the permissions they need to run and log to CloudWatch.

Central and Regional S3 Buckets: It creates a central S3 bucket in us-west-1 for your main code. Then, it creates a separate S3 bucket in each target region (ap-south-1 and ap-southeast-1). This is the key step to work around AWS's same-region requirement for Lambda code from S3.

S3 Object Upload: The aws_s3_object resource is used to upload the lambda_code.zip file to each of the regional S3 buckets. This ensures that a copy of your code is available in each region where a Lambda function will be deployed.

Lambda Function Creation: The aws_lambda_function resources in the main.tf file explicitly define a Lambda function for each region. Each function's s3_bucket and s3_key arguments point to the local, regional S3 bucket containing the code.

EventBridge Trigger: The aws_cloudwatch_event_rule and aws_cloudwatch_event_target resources create the Cron scheduler and link it to the correct Lambda function in each region, setting up the automated trigger.

So, in summary, you're not just creating the infrastructure; you're also deploying the application code itself as part of the Terraform apply process. This is the "Infrastructure as code" approach in action
