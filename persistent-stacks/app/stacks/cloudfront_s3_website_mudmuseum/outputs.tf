output "cloudfront_distribution_id" {
  description = "The CloudFront Distribution ID used with the IAM Policy."
  value       = module.cloudfront_distribution.cloudfront_distribution_id
}
