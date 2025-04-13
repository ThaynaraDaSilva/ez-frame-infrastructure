resource "aws_dynamodb_table" "video_metadata" {
  name         = "video_metadata"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "videoId"

  attribute {
    name = "videoId"
    type = "S"
  }

  tags = local.default_tags
}
