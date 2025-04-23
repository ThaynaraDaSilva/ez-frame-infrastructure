resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

 tags = merge(
    local.default_tags,
    {
      Name = "${local.name_prefix}-igw"
    }
  )
}