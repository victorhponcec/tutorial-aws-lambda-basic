#Configuring AWS Provider
provider "aws" {
  region = "us-east-1"
}

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

#Policy Attachment 
resource "aws_iam_role_policy_attachment" "attach_role_policy_lambda" {
  role       = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.lambda.arn
}

#ZIP code for Lambda
data "archive_file" "zip_py" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_code/"
  output_path = "${path.module}/lambda_code/lambda.zip"
}

#Lambda Function
resource "aws_lambda_function" "lambda_hello" {
  filename = "${path.module}/lambda_code/lambda.zip"
  function_name = "lambda_hello_py"
  role = aws_iam_role.lambda.arn
  handler = "lambda.hello_handler"
  runtime = "python3.8"
  depends_on = [ aws_iam_role_policy_attachment.attach_role_policy_lambda ]
}