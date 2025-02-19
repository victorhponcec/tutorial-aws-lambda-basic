# Tutorial: Creating a basic Lambda function in AWS with Terraform
AWS | Terraform | Lambda Function | Serverless

# Summary
In this small tutorial we are going to create a Lambda function in AWS using Infrastructure as Code (IaC) with Terraform.

# Lambda Code

The first thing we are going to do is to create our code in Python. Create a folder called lambda_code and inside a file lambda.py. We’ll later generate a ZIP file from this. 

```
def hello_handler(event, context):
    #Lambda function to greet a user with their full name.
    first_name = event.get("first_name", "Guest")
    last_name = event.get("last_name", "")
    return {
        "statusCode": 200,
        "body": f"Hello, {first_name} {last_name}!"
    }
```

# Setting up the Providers

For this tutorial we’ll only need the AWS provider. We are using the latest version "5.87.0".
You can find more information about the AWS Provider in the [Terraform Registry](https://registry.terraform.io/providers/hashicorp/aws/latest)

```
terraform {
  required_version = "~> 1.10.2"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.87.0"
    }
  }
}
```

We need to give Lambda permissions, for which we need to create a role to be assumed by our Lambda function and an IAM Policy with basic permissions. 

```
#IAM Role/Trust Policy for Lambda
resource "aws_iam_role" "lambda" {
  name               = "hello_lambda_function"
  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "lambda.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}

#IAM Policy For Lambda
resource "aws_iam_policy" "lambda" {
  name        = "policy_for_lambda"
  path        = "/"
  description = "IAM Policy for the Lamnda Role"
  policy      = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": [
       "logs:CreateLogGroup",
       "logs:CreateLogStream",
       "logs:PutLogEvents"
     ],
     "Resource": "arn:aws:logs:*:*:*",
     "Effect": "Allow"
   }
 ]
}
EOF
}
```

Now we need to attach the IAM Role to the Policy just created

```
#Policy Attachment 
resource "aws_iam_role_policy_attachment" "attach_role_policy_lambda" {
  role       = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.lambda.arn
}
```

# Creating a ZIP file for our Lambda

Now we need to create a ZIP file containing our Python code, which will be uploaded to AWS. 

```
#ZIP code for Lambda
data "archive_file" "zip_py" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_code/"
  output_path = "${path.module}/lambda_code/lambda.zip"
}
```
# Creating our Lambda Function

Finally, we can create our lambda function. Notice that we are referencing the ZIP file and the role, as well as the policy attachment. 

```
#Lambda Function
resource "aws_lambda_function" "lambda_hello" {
  filename = "${path.module}/lambda_code/lambda.zip"
  function_name = "lambda_hello_py"
  role = aws_iam_role.lambda.arn
  handler = "lambda.hello_handler"
  runtime = "python3.8"
  depends_on = [ aws_iam_role_policy_attachment.attach_role_policy_lambda ]
}
```
# Apply Changes

On our local console we need to initialize our project, plan and apply. 

```
terraform init
terraform plan
terraform apply 
```

# Testing

We can verify our Lambda function in the AWS Management Console by navigating to Lambda > Functions > lambda_hello_py

![imagen](https://github.com/user-attachments/assets/dfd7fb5c-e672-4be0-be4c-b770bca6eaee)

On the same screen, go to the "Test" tab and edit the Event Json with the following code, which will pass the variables to our Lambda Function to be processed. 

```
{
  "first_name": "victor",
  "last_name": "ponce"
}
```

Click on Test and you should be able to see a successful execution. 

![imagen](https://github.com/user-attachments/assets/a8d4dc16-186a-4112-87be-a550cb4700cf)



