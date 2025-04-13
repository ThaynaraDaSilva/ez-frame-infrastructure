locals{
    env = "dev"
    project = "ez-frame-generator"
    region = "us-east-1"
    zone1 = "us-east-1a"
    zone2 = "us-east-1b"
    eks_name = "ez-frame-generator"
    eks_version = "1.32"

    name_prefix = "${local.project}-${local.env}"

    default_tags = {
        Project = local.project
        Environment = local.env
        ManagedBy = "Terraform"
  }
}