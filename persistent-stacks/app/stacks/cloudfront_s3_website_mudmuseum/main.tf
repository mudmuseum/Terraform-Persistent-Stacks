module "s3_bucket_website" {
  source                                 = "github.com/mudmuseum/terraform-modules.git//modules/s3?ref=v0.0.17"

  bucket                                 = "mudmuseum.com"
  logging_target_bucket                  = "mudmuseum-logs"
  logging_target_prefix                  = "mudmuseum-s3-bucket-server-access-logging"
}

data "aws_canonical_user_id" "current" { }

module "s3_bucket_logs" {
  source                                 = "github.com/mudmuseum/terraform-modules.git//modules/s3?ref=v0.0.17"

  bucket                                 = "mudmuseum-logs"
  lifecycle_id                           = "Cleanup old files"
  enabled                                = true
  abort_incomplete_multipart             = "5"
  expiration_days                        = "5"
  expired_object_delete_marker           = false
  noncurrent_days                        = "5"

  grants = [
    {
      "id"          = "",
      "permissions" = ["READ_ACP", "WRITE"],
      "type"        = "Group",
      "uri"         = "http://acs.amazonaws.com/groups/s3/LogDelivery"
    },
    # Local user
    {
      "id"          = data.aws_canonical_user_id.current.id,
      "permissions" = ["FULL_CONTROL"],
      "type"        = "CanonicalUser",
      "uri"         = ""
    },
    # CloudFront has a static ID
    {
      "id"          = "c4c1ede66af53448b93c283ce9448c4ba468c9432aa01d700d3878632f77d2d0",
      "permissions" = ["FULL_CONTROL"],
      "type"        = "CanonicalUser",
      "uri"         = ""
    }
  ]
}

module "cloudfront_origin_access_identity" {
  source                                 = "github.com/mudmuseum/terraform-modules.git//modules/cloudfront_origin_access_identity?ref=v0.0.17"

  comment                                = "access-identity-"
}

module "cloudfront_cache_policy" {
  source                                 = "github.com/mudmuseum/terraform-modules.git//modules/cloudfront_cache_policy?ref=v0.0.17"
}

module "acm_certificate" {
  source                                 = "github.com/mudmuseum/terraform-modules.git//modules/acm_certificate?ref=v0.0.17"

  domain_name                            = "mudmuseum.com"
  subject_alternative_names              = ["web.mudmuseum.com", "www.mudmuseum.com"]
}

module "cloudfront_distribution" {
  source                                 = "github.com/mudmuseum/terraform-modules.git//modules/cloudfront_distribution?ref=v0.0.17"

  bucket_regional_domain_name            = module.s3_bucket_website.bucket_regional_domain_name
  cloudfront_origin_origin_id            = "S3-mudmuseum.com"
  origin_access_identity_cloudfront_path = module.cloudfront_origin_access_identity.cloudfront_access_identity_path
  cloudfront_comment                     = "Managed by Terraform"
  cloudfront_logging_bucket              = join(".", [module.s3_bucket_logs.name, "s3.amazonaws.com"])
  cloudfront_logging_prefix              = "logdir/"
  cloudfront_aliases                     = ["mudmuseum.com", "web.mudmuseum.com", "www.mudmuseum.com"]
  cloudfront_cache_policy_id             = module.cloudfront_cache_policy.id
  acm_certificate_arn                    = module.acm_certificate.arn
}
