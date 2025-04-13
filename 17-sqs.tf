
# data "aws_iam_policy" "existing_sqs_access" {
#   name = "EKS-SQS-Access"
# }

resource "aws_sqs_queue" "order_payment_dlq" {
  name                      = "${local.project}-order-payment-dlq-${local.env}"
  message_retention_seconds = 86400  # 1 dia de retenção

  tags = {
    Name = "order-payment-dlq"
    project = "${local.project}"
  }
}

resource "aws_sqs_queue" "order_payment_queue" {
  name                      = "${local.project}-order-payment-queue-${local.env}"
  message_retention_seconds = 86400  # 1 dia de retenção
  visibility_timeout_seconds = 30  # Mensagem fica "invisivel" por 30s após recebida
  max_message_size          = 262144  # 256 KB (máximo permitido)
  delay_seconds             = 0  # Sem atraso na entrega das mensagens
  receive_wait_time_seconds = 0  # Sem espera para pooling de mensagens

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.order_payment_dlq.arn
    maxReceiveCount     = 3  # Mensagem sera movida para DLQ após 3 tentativas
  })

  tags = {
    Name = "order-payment-queue"
    project = "${local.project}"
  }
}

# resource "aws_iam_policy" "sqs_access" {
#   count = length(data.aws_iam_policy.existing_sqs_access.arn) > 0 ? 0 : 1
#   name        = "EKS-SQS-Access"
#   description = "Permite que os nodes do EKS acessem a fila SQS"
  
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = [
#           "sqs:SendMessage",
#           "sqs:ReceiveMessage",
#           "sqs:DeleteMessage",
#           "sqs:GetQueueAttributes",
#           "sqs:GetQueueUrl"
#         ]
#         Resource = aws_sqs_queue.order_payment_queue.arn
#       }
#     ]
#   })
# }

# resource "aws_iam_role_policy_attachment" "eks_sqs_attach" {
#   role       = aws_iam_role.nodes.name  # Nome do role dos nodes do EKS
#   policy_arn = aws_iam_policy.sqs_access.arn
# }

resource "aws_sqs_queue_policy" "sqs_policy" {
  queue_url = aws_sqs_queue.order_payment_queue.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = "*"
        Action = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage"
        ]
        Resource = aws_sqs_queue.order_payment_queue.arn
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = "arn:aws:execute-api:us-east-1:123456789012:api-id/*"
          }
        }
      }
    ]
  })
}
