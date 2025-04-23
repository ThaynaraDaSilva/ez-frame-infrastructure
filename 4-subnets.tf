# Subnet Privadas
resource "aws_subnet" "private_zone1" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.0.0/19"
  availability_zone = local.zone1
  tags = merge(
    local.default_tags,
    {
      "Name"                                                  = "${local.name_prefix}-private-${local.zone1}"
      "Kubernetes.io/role/internal-elb"                       = "1"
      "Kubernetes.io/cluster/${local.eks_name}"               = "owned"
    }
  )
}

resource "aws_subnet" "private_zone2" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.32.0/19"
  availability_zone = local.zone2
  
  tags = merge(
    local.default_tags,
    {
      "Name"                                                  = "${local.name_prefix}-private-${local.zone2}"
      "Kubernetes.io/role/internal-elb"                       = "1"
      "Kubernetes.io/cluster/${local.eks_name}"               = "owned"
    }
  )
}

# subnet Publicas
resource "aws_subnet" "public_zone1" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.64.0/19"
  availability_zone = local.zone1
  map_public_ip_on_launch = true
  tags = merge(
    local.default_tags,
    {
      "Name"                                                 = "${local.name_prefix}-public-${local.zone1}"
      "Kubernetes.io/role/elb"                               = "1"
      "Kubernetes.io/cluster/${local.eks_name}"              = "owned"
    }
  )
}

resource "aws_subnet" "public_zone2" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.96.0/19"
  availability_zone = local.zone2
  map_public_ip_on_launch = true
  tags = merge(
    local.default_tags,
    {
      "Name"                                                 = "${local.name_prefix}-public-${local.zone2}"
      "Kubernetes.io/role/elb"                               = "1"
      "Kubernetes.io/cluster/${local.eks_name}"              = "owned"
    }
  )
}