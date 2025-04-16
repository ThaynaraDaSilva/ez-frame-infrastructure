resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "1.7.1" # Pin version for stability
  namespace  = "kube-system"

  values = [
    yamlencode({
      clusterName = aws_eks_cluster.eks.name

      serviceAccount = {
        create = false
        name   = kubernetes_service_account.alb_controller.metadata[0].name
      }

      region = local.region
      vpcId  = aws_vpc.main.id

      image = {
        tag = "v2.7.1" # Match ALB Controller image to chart version
      }
    })
  ]

  depends_on = [
    aws_iam_role_policy_attachment.alb_controller_policy_attach,
    kubernetes_service_account.alb_controller
  ]
}
