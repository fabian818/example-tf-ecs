resource "aws_iam_role" "default" {
  name = "${local.prefix}-function-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF

}

resource "aws_iam_policy" "lambda_logging" {
  name        = "${local.prefix}-function-logs-policy"
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

resource "aws_iam_policy" "cognito" {
  name        = "${local.prefix}-function-cognito-policy"
  description = "IAM policy for cognito idp access from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "cognito-idp:*"
      ],
      "Resource": "*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "ecs" {
  name        = "${local.prefix}-function-ecs-policy"
  description = "IAM policy for ecs access from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ecs:*"
      ],
      "Resource": "*",
      "Effect": "Allow"
    },
    {
      "Action": [
        "iam:*"
      ],
      "Resource": "*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ec2_attach" {
  role       = aws_iam_role.default.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}


resource "aws_iam_role_policy_attachment" "logs_attach" {
  role       = aws_iam_role.default.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}


resource "aws_iam_role_policy_attachment" "cognito_attach" {
  role       = aws_iam_role.default.name
  policy_arn = aws_iam_policy.cognito.arn
}


resource "aws_iam_role_policy_attachment" "ecs_attach" {
  role       = aws_iam_role.default.name
  policy_arn = aws_iam_policy.ecs.arn
}

resource "aws_cloudwatch_log_group" "default" {
  name              = "/aws/lambda/${aws_lambda_function.default.function_name}"
  retention_in_days = 14
}

resource "aws_lambda_function" "default" {
  function_name    = "${local.prefix}-function"
  filename         = var.filename
  role             = aws_iam_role.default.arn
  handler          = var.handler
  source_code_hash = var.source_code_hash

  runtime = var.runtime

  environment {
    variables = var.variables
  }

  dynamic "vpc_config" {
    for_each = var.subnet_ids != null ? { x = "x" } : {}

    content {
      subnet_ids         = var.subnet_ids
      security_group_ids = var.security_group_ids
    }
  }
}
