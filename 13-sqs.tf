# Dead Letter Queue
resource "aws_sqs_queue" "video_processing_dlq" {
  name = "video-processing-queue-dlq"

  tags = local.default_tags
}

# Main Queue com redrive policy para DLQ
resource "aws_sqs_queue" "video_processing" {
  name = "video-processing-queue"

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.video_processing_dlq.arn
    maxReceiveCount     = 3
  })

  tags = local.default_tags
}
