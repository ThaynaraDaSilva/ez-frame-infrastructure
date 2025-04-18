# Elastic IP para o NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"
  tags = merge(
    local.default_tags,
    {
      Name = "${local.name_prefix}-nat-eip"
    }
  )
}

# NAT Gateway na zona 1 (pode duplicar para alta disponibilidade)
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_zone1.id
  tags = merge(
    local.default_tags,
    {
      Name = "${local.name_prefix}-nat-gw"
    }
  )
  depends_on = [aws_internet_gateway.igw]
}