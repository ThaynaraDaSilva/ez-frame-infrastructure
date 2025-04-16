resource "aws_iam_policy" "alb_controller_policy" {
  name        = "AWSLoadBalancerControllerIAMPolicy"
  path        = "/"
  description = "Policy for ALB controller"
  policy      = file("${path.module}/iam/iam-policy.json")
}


# Assume role policy para o ServiceAccount do frame-generator
data "aws_iam_policy_document" "frame_generator_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:ez-frame-generator-namespace:frame-generator-sa"]
    }
  }
}

# Role que será assumida pelo pod no Fargate via IRSA
resource "aws_iam_role" "frame_generator_access_role" {
  name               = "${local.name_prefix}-access-role"
  assume_role_policy = data.aws_iam_policy_document.frame_generator_assume_role.json
  tags               = local.default_tags
}

# Permissões para acessar S3, SQS e DynamoDB
resource "aws_iam_role_policy" "frame_generator_policy" {
  name = "${local.name_prefix}-access-policy"
  role = aws_iam_role.frame_generator_access_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ],
        Resource = [
          "arn:aws:s3:::ez-frame-video-storage",
          "arn:aws:s3:::ez-frame-video-storage/*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ],
        Resource = aws_sqs_queue.video_processing.arn
      },
      {
        Effect = "Allow",
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ],
        Resource = aws_dynamodb_table.video_metadata.arn
      }
    ]
  })
}

