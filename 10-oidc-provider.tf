data "aws_eks_cluster" "eks" {
  name = aws_eks_cluster.eks.name
  depends_on = [aws_eks_cluster.eks]
}

resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]

  # Fix: SHA-1 do certificado raiz da CA da AWS OIDC para us-east-1
  thumbprint_list = ["9e99a48a9960b14926bb7f3b02e22da0afd29ec7"]

  url = data.aws_eks_cluster.eks.identity[0].oidc[0].issuer
}