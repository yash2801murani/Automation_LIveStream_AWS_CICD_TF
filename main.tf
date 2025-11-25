terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

########################################
# IVS Channel
########################################
resource "aws_ivs_channel" "live" {
  name         = "live-demo-channel"
  latency_mode = "LOW"
  type         = "BASIC"
}

########################################
# IVS Stream Key (data)
########################################
data "aws_ivs_stream_key" "stream_key" {
  channel_arn = aws_ivs_channel.live.arn
}

########################################
# S3 Bucket For HTML Video Player
########################################
resource "aws_s3_bucket" "site" {
  bucket = var.bucket_name
}

# Allow public bucket policy
resource "aws_s3_bucket_public_access_block" "public" {
  bucket                  = aws_s3_bucket.site.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Public bucket policy for index.html
resource "aws_s3_bucket_policy" "public_policy" {
  bucket = aws_s3_bucket.site.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.site.arn}/*"
      }
    ]
  })
}

########################################
# Upload HTML file (no ACL)
########################################
resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.site.id
  key          = "index.html"
  content_type = "text/html"

  content = <<EOF
<!DOCTYPE html>
<html>
  <body>
    <h2>AWS IVS Live Stream</h2>
    <video width="600" controls autoplay src="${aws_ivs_channel.live.playback_url}"></video>
  </body>
</html>
EOF
}
