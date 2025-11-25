variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "bucket_name" {
  description = "S3 bucket name for website (must be globally unique)"
  type        = string
  default     = "yash-ivs-demo-site-12345"
}

variable "channel_name" {
  description = "IVS channel name"
  type        = string
  default     = "yash-live-channel"
}
