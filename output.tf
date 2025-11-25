output "ivs_channel_arn" {
  value = aws_ivs_channel.live.arn
}

output "ivs_playback_url" {
  value = aws_ivs_channel.live.playback_url
}

output "ivs_stream_key" {
  value     = data.aws_ivs_stream_key.stream_key.value
  sensitive = true
}

output "s3_index_url" {
  value = "http://${aws_s3_bucket.site.bucket}.s3.amazonaws.com/index.html"
}

