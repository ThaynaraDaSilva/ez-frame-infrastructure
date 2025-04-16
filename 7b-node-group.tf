resource "aws_eks_node_group" "system_node_group" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "${local.name_prefix}-system-ng"
  node_role_arn   = aws_iam_role.eks_node.arn
  subnet_ids = [
    aws_subnet.public_zone1.id,
    aws_subnet.public_zone2.id
  ]

  instance_types = ["t3.small"]
  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  tags = merge(
    local.default_tags,
    {
      "k8s.io/cluster-autoscaler/enabled"                 = "true"
      "k8s.io/cluster-autoscaler/${local.name_prefix}"    = "owned"
    }
  )
}