resource "aws_s3_bucket" "frame_storage" {
  bucket = "ez-frame-video-storage"

  tags = local.default_tags
}
