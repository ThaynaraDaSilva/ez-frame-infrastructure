resource "aws_security_group" "alb_sg" {
  name        = "${local.project}-alb-sg-${local.env}"
  description = "Security Group for ALB"
  vpc_id      = aws_vpc.main.id

  # Permitir tráfego HTTP de qualquer origem (0.0.0.0/0)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Permitir tráfego de saída para qualquer destino
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${local.project}-alb-sg-${local.env}"
    project = "${local.project}"
  }
}
