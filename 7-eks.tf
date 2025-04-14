# =========================================================
# Security Group para o cluster EKS
# =========================================================
resource "aws_security_group" "eks_cluster_sg" {
  name        = "${local.name_prefix}-eks-sg"
  description = "Security Group for EKS Cluster"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Para setup inicial. Depois, limitar IP.
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.default_tags,
    {
      Name = "${local.name_prefix}-eks-sg"
    }
  )
}

# =========================================================
# IAM Role para o cluster EKS
# =========================================================
resource "aws_iam_role" "eks" {
  name = "${local.name_prefix}-eks-cluster-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "eks.amazonaws.com"
      }
    }
  ]
}
POLICY

  tags = local.default_tags
}

# Permissão necessária para EKS operar
resource "aws_iam_role_policy_attachment" "eks" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks.name
}

# =========================================================
# Criação do cluster EKS
# =========================================================
resource "aws_eks_cluster" "eks" {
  name     = "${local.name_prefix}-cluster"
  version  = local.eks_version
  role_arn = aws_iam_role.eks.arn

  vpc_config {
    endpoint_private_access = true
    endpoint_public_access  = true

    subnet_ids = [
      aws_subnet.private_zone1.id,
      aws_subnet.private_zone2.id,
      aws_subnet.public_zone1.id,
      aws_subnet.public_zone2.id
    ]

    security_group_ids = [aws_security_group.eks_cluster_sg.id]
  }

  access_config {
    authentication_mode                          = "API"
    bootstrap_cluster_creator_admin_permissions  = true
  }

  tags = local.default_tags

  depends_on = [aws_iam_role_policy_attachment.eks]
}

# =========================================================
# Data sources e provider Kubernetes (acesso ao cluster)
# =========================================================
data "aws_eks_cluster" "eks" {
  name = aws_eks_cluster.eks.name
}

data "aws_eks_cluster_auth" "eks" {
  name = aws_eks_cluster.eks.name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks.token
}

# =========================================================
# Namespace para uso com Fargate
# =========================================================
resource "kubernetes_namespace" "frame_generator" {
  metadata {
    name = "ez-frame-generator-namespace"
  }
}
