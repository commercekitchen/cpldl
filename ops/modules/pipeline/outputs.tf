output "artifact_s3_bucket_arn" {
  value = aws_s3_bucket.pipeline_store.arn
}