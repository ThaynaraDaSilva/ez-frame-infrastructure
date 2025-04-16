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

# Tabela de rota para subnets privadas
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = merge(
    local.default_tags,
    {
      Name = "${local.name_prefix}-private-rt"
    }
  )
}

# Associação da tabela privada com as subnets privadas
resource "aws_route_table_association" "private_zone1" {
  subnet_id      = aws_subnet.private_zone1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_zone2" {
  subnet_id      = aws_subnet.private_zone2.id
  route_table_id = aws_route_table.private.id
}