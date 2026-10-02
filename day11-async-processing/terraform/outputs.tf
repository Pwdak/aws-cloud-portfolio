output "raw_bucket_name" {
  value = aws_s3_bucket.raw.id
}

output "valid_bucket_name" {
  value = aws_s3_bucket.valid.id
}

output "dlq_url" {
  value = aws_sqs_queue.dlq.url
}