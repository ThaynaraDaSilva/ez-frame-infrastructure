# data "aws_lb_target_group" "existing_tg" {
#   name = "ez-fastfood-tg"
# }
resource "aws_lb" "alb" {
  name               = "${local.project}-alb-${local.env}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets           = [aws_subnet.public_zone1.id, aws_subnet.public_zone2.id]
}

# resource "aws_lb_target_group" "tg" {
  
#   #count = length(data.aws_lb_target_group.existing_tg.arn) > 0 ? 0 : 1

#   name     = "ez-fastfood-tg"
#   port     = 80
#   protocol = "HTTP"
#   vpc_id   = aws_vpc.main.id
# }

# resource "aws_lb_listener" "listener" {
#   load_balancer_arn = aws_lb.alb.arn
#   port              = 80
#   protocol          = "HTTP"

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.tg.arn
#   }
# }
## adicionar HTTPS ao ALB (Seguranca)
#resource "aws_lb_listener" "https_listener" {
#  load_balancer_arn = aws_lb.alb.arn
#  port              = 443
#  protocol          = "HTTPS"
#  ssl_policy        = "ELBSecurityPolicy-2016-08"
#  certificate_arn   = "arn:aws:acm:us-east-1:ACCOUNT_ID:certificate/CERTIFICATE_ID"
#
#  default_action {
#    type             = "forward"
#    target_group_arn = aws_lb_target_group.tg.arn
#  }
#}

## Criar Certificado gratuíto no AWS ACM
#aws acm request-certificate --domain-name "meusite.com" --validation-method DNS --region us-east-1

