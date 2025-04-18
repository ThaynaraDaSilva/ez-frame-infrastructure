resource "aws_security_group" "eks_nodes_sg" {
  name        = "${local.name_prefix}-node-sg"
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
  name = "${local.name_prefix}-nodes"
  assume_role_policy = file("${path.module}/iam/eks-node-role.json")
  tags = local.default_tags
}

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
}

resource "aws_eks_node_group" "ez_frame_generator_node" {
  cluster_name  = aws_eks_cluster.eks.name
  node_group_name  = "${local.name_prefix}-node"
  node_role_arn  = aws_iam_role.nodes.arn
  subnet_ids      = [aws_subnet.private_zone1.id, aws_subnet.private_zone2.id]

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  capacity_type  = "ON_DEMAND"
  instance_types = ["t3.medium"]

 tags = merge(
    local.default_tags,
    {
      Name = "ez-frame-generator-node"
    }
  )
}

