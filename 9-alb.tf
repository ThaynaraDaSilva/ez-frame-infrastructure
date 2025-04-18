resource "aws_lb" "alb" {
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets           = [aws_subnet.public_zone1.id, aws_subnet.public_zone2.id]

tags = merge(
    local.default_tags,
    {
      Name = "${local.name_prefix}-alb"
    }
  )
}