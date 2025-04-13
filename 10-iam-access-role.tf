data "aws_iam_policy_document" "frame_generator_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.eks.id]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:ez-frame-generator-namespace:frame-generator-sa"]
    }
  }
}

resource "aws_iam_role" "frame_generator_access_role" {
  name = "${local.name_prefix}-access-role"
  assume_role_policy = data.aws_iam_policy_document.frame_generator_assume_role.json

  tags = local.default_tags
}

resource "aws_iam_role_policy" "frame_generator_policy" {
  name = "${local.name_prefix}-access-policy"
  role = aws_iam_role.frame_generator_access_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
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
        Effect   = "Allow",
        Action   = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ],
        Resource = aws_sqs_queue.video_processing.arn
      },
      {
        Effect   = "Allow",
        Action   = [
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

# OIDC Provider do EKS
data "aws_eks_cluster" "eks" {
  name = aws_eks_cluster.eks.name
}

data "aws_eks_cluster_auth" "eks" {
  name = aws_eks_cluster.eks.name
}

resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.aws_eks_cluster_auth.eks.certificate_authority.0.data]
  url             = data.aws_eks_cluster.eks.identity.0.oidc.0.issuer
}