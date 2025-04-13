resource "aws_security_group" "eks_nodes_sg" {
  name        = "eks-nodes-sg"
  description = "Security Group for EKS Worker Nodes"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    self        = true
  }

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_cluster_sg.id]  # FIXED: Worker nodes talk to EKS API
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_role" "nodes" {
  name = "${local.eks_name}-eks-nodes-${local.env}"

  assume_role_policy = <<POLICY
  {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "sts:AssumeRole",
            "Principal": {
                "Service": "ec2.amazonaws.com"
            }
        }
    ]
  }
POLICY
}

# eks worker node policy
resource "aws_iam_role_policy_attachment" "amazon_eks_worker_node_policy"{
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
    role = aws_iam_role.nodes.name
}

# eks cni policy - manage secondary IPs for pods
resource "aws_iam_role_policy_attachment" "amazon_eks_cni_policy"{
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
    role = aws_iam_role.nodes.name
}

# AmazonEC2Container Registry Read Only to pull private Docker images from ECR container Registry
resource "aws_iam_role_policy_attachment" "amazon_ec2_container_registry_read_only"{
    policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
    role = aws_iam_role.nodes.name
    #role       = aws_iam_role.nodes.arn  # Change from .name to .arn
}

resource "aws_eks_node_group" "general" {
  cluster_name  = aws_eks_cluster.eks.name
  version       = local.eks_version
  node_group_name = "${local.project}-node-group-general"
  node_role_arn  = aws_iam_role.nodes.arn

  subnet_ids = [
    aws_subnet.private_zone1.id,
    aws_subnet.private_zone2.id
  ]

  capacity_type  = "ON_DEMAND"
  instance_types = ["t3.medium"] # ajuste aplicado

  scaling_config {
    desired_size = 1 # 4 para microsservicos e 1 para EKS
    max_size = 2 # expansao maxima se necessario pensando em falha
    min_size = 1 # redundancia minima
  }
  # cluster upgrades
  update_config {
    max_unavailable = 1
  }
  labels = {
    role = "general"
    "project" = "${local.project}"
  }

  # wait until IAM Role and policies are created and attached
  depends_on = [ 
    aws_iam_role_policy_attachment.amazon_eks_worker_node_policy,
    aws_iam_role_policy_attachment.amazon_eks_cni_policy,
    aws_iam_role_policy_attachment.amazon_ec2_container_registry_read_only
   ]

  # allow external changes without Terraform plan difference
   lifecycle {
     ignore_changes = [ scaling_config[0].desired_size ]
   }
}

resource "aws_eks_node_group" "order_nodes" {
  cluster_name  = aws_eks_cluster.eks.name
  node_role_arn  = aws_iam_role.nodes.arn
  node_group_name = "${local.project}-node-group-order"
  subnet_ids      = [aws_subnet.private_zone1.id, aws_subnet.private_zone2.id]

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  instance_types = ["t3.medium"]

  labels = {
    "service" = "order"
    "project" = "${local.project}"
  }
}

resource "aws_eks_node_group" "payment_nodes" {
  cluster_name  = aws_eks_cluster.eks.name
  node_role_arn  = aws_iam_role.nodes.arn
  node_group_name = "${local.project}-node-group-payment"
  subnet_ids      = [aws_subnet.private_zone1.id, aws_subnet.private_zone2.id]

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  instance_types = ["t3.medium"]

  labels = {
    "service" = "payment"
    "project" = "${local.project}"
  }
}

/*resource "aws_eks_node_group" "user_nodes" {
  cluster_name  = aws_eks_cluster.eks.name
  node_role_arn  = aws_iam_role.nodes.arn
  node_group_name = "${local.project}-node-group-user"
  subnet_ids      = [aws_subnet.private_zone1.id, aws_subnet.private_zone2.id]

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  instance_types = ["t3.medium"]

  labels = {
    "service" = "user"
    "project" = "${local.project}"
  }
}*/

resource "aws_eks_node_group" "catalog_nodes" {
  cluster_name  = aws_eks_cluster.eks.name
  node_role_arn  = aws_iam_role.nodes.arn
  node_group_name = "${local.project}-node-group-catalog"
  subnet_ids      = [aws_subnet.private_zone1.id, aws_subnet.private_zone2.id]

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  instance_types = ["t3.medium"]

  labels = {
    "service" = "catalog"
    "project" = "${local.project}"
  }
}