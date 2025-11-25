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

# Block public access
resource "aws_s3_bucket_public_access_block" "public" {
  bucket                  = aws_s3_bucket.site.id
  block_public_policy     = true
  block_public_acls       = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}

# Allow CloudFront OAC to access bucket
resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.site.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowCloudFrontRead"
        Effect    = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.site.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.cdn.arn
          }
        }
      }
    ]
  })
}

########################################
# Upload HTML file
########################################
resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.site.id
  key          = "index.html"

  content = <<EOF
<!DOCTYPE html>
<html>
  <body>
    <h2>AWS IVS Live Stream</h2>
    <video width="600" controls autoplay src="${aws_ivs_channel.live.playback_url}"></video>
  </body>
</html>
EOF

  content_type = "text/html"
}

########################################
# CloudFront Origin Access Control (OAC)
########################################
resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "s3-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

########################################
# CloudFront Distribution
########################################
resource "aws_cloudfront_distribution" "cdn" {
  enabled = true

  origin {
    domain_name              = aws_s3_bucket.site.bucket_regional_domain_name
    origin_id                = "s3-origin"
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
  }

  default_cache_behavior {
    target_origin_id       = "s3-origin"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}
