terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = "us-west-2"
}

resource "aws_s3_bucket" "hackernews_project_bucket" {
  bucket = "hackernews-project-bucket-g3dg6gf4fddk"
  acl    = "private"
}

resource "aws_iam_role" "lambda_hackernews_etl" {
  name = "iam_role_hackernews_etl"

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

# See also the following AWS managed policy: AWSLambdaBasicExecutionRole
resource "aws_iam_policy" "lambda_hackernews_etl" {
  name        = "lambda_logging"
  path        = "/"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
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

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_hackernews_etl.name
  policy_arn = aws_iam_policy.lambda_hackernews_etl.arn
}

resource "aws_lambda_layer_version" "lambda_layer_hackernews_etl" {
  filename   = "dist/lambda_layer_hackernews_etl.zip"
  layer_name = "lambda_layer_hackernews_etl"

  compatible_runtimes = ["python3.8"]
}

resource "aws_lambda_function" "lambda_hackernews_etl" {
  filename      = "dist/lambda_hackernews_etl.zip"
  function_name = "lambda_import_main_stories_by_day"
  role          = aws_iam_role.lambda_hackernews_etl.arn
  handler       = "lambda_import_main_stories_by_day.main"

  source_code_hash = format(
    "%s-%s",
    filebase64sha256(aws_lambda_function.lambda_hackernews_etl.filename),
    aws_iam_role.lambda_hackernews_etl.name
  )

  runtime     = "python3.8"
  memory_size = 128
  timeout     = 20

  layers = [aws_lambda_layer_version.lambda_layer_hackernews_etl.arn]

  environment {
    variables = {
      foo = "bar"
    }
  }
}