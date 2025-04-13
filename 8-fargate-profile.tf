# Role para pods em Fargate
resource "aws_iam_role" "fargate_pod_execution" {
  name = "${local.name_prefix}-fargate-pod-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "eks-fargate-pods.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = local.default_tags
}

# Políticas necessárias para execução de pods Fargate
resource "aws_iam_role_policy_attachment" "fargate_pod_execution" {
  role       = aws_iam_role.fargate_pod_execution.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
}

# Fargate Profile (associa o namespace `ez-frame-generator` às subnets públicas)
resource "aws_eks_fargate_profile" "default" {
  cluster_name           = aws_eks_cluster.eks.name
  fargate_profile_name   = "${local.name_prefix}-fargate"
  pod_execution_role_arn = aws_iam_role.fargate_pod_execution.arn

  subnet_ids = [
    aws_subnet.private_zone1.id,
    aws_subnet.private_zone2.id
  ]
  
  selector {
    namespace = "ez-frame-generator-namespace"
  }

  tags = local.default_tags

  depends_on = [
    aws_iam_role_policy_attachment.fargate_pod_execution
  ]
}