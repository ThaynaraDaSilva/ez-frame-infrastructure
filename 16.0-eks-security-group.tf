resource "aws_security_group" "eks_nodes" {
  name        = "eks-nodes-sg-${local.env}"
  description = "Security Group para os nos do EKS"
  vpc_id      = aws_vpc.main.id

  # Permite tráfego entre os nós do cluster EKS
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    self        = true
  }

  # Permitir tráfego para o banco de dados
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    #security_groups = [aws_security_group.db_sg.id]
    cidr_blocks = ["10.0.0.0/16"]  # Permitir acesso dentro da própria VPC
  }

  # Permitir saída de tráfego para qualquer destino (internet ou outros serviços internos)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "eks-nodes-sg-${local.env}"
    project = "${local.project}"
  }
}