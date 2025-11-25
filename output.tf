output "ivs_channel_arn" {
  value = aws_ivs_channel.live.arn
}

output "ivs_playback_url" {
  value = aws_ivs_channel.live.playback_url
}

output "ivs_ingest_endpoint" {
  value = aws_ivs_channel.live.ingest_endpoint
}

output "ivs_stream_key" {
  description = "Stream key (sensitive) - give to admin"
  value       = aws_ivs_stream_key.key.value
  sensitive   = true
}

output "s3_website_bucket" {
  value = aws_s3_bucket.site.bucket
}

output "cloudfront_domain" {
  value = aws_cloudfront_distribution.cdn.domain_name
}
