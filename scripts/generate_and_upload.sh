#!/bin/bash
set -euo pipefail

# Expect env vars: PLAYBACK_URL, S3_BUCKET, CLOUDFRONT_DIST (optional)
if [ -z "${PLAYBACK_URL:-}" ]; then
  echo "PLAYBACK_URL not set"
  exit 2
fi
if [ -z "${S3_BUCKET:-}" ]; then
  echo "S3_BUCKET not set"
  exit 2
fi

# Replace placeholder and create final index.html
sed "s|{{PLAYBACK_URL}}|${PLAYBACK_URL}|g" website/index.html > website/index.final.html

# Upload to S3 (private bucket - CloudFront will serve to users)
aws s3 cp website/index.final.html s3://${S3_BUCKET}/index.html --content-type "text/html"

# Invalidate CloudFront cache (if distribution provided)
if [ -n "${CLOUDFRONT_DIST:-}" ]; then
  aws cloudfront create-invalidation --distribution-id ${CLOUDFRONT_DIST} --paths /index.html
fi

echo "Uploaded index.html to s3://${S3_BUCKET}/index.html"
