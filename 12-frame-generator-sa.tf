resource "kubernetes_service_account" "frame_generator" {
  metadata {
    name      = "frame-generator-sa"
    namespace = "ez-frame-generator-namespace"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.frame_generator_access_role.arn
    }
  }
}
