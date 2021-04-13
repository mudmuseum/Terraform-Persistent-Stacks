data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "iam_policy_document_github_actions" {

  statement {
    actions     = [ "cloudfront:ListDistributions" ]
    resources   = [ "*" ]
  }
  statement {
    actions     = [ "s3:PutObject",
                    "s3:AbortMultipartUpload",
                    "s3:DeleteObjectVersion",
                    "s3:ListBucket",
                    "s3:DeleteObject",
                    "cloudfront:CreateInvalidation" ]
    resources   = [ "arn:aws:s3:::mudmuseum.com/",
                    "arn:aws:s3:::mudmuseum.com/*", 
                    "arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:distribution/${var.cloudfront_distribution_id}" ]
  }
}

module "iam_policy_github_actions_website" {
  source      = "github.com/mudmuseum/terraform-modules.git//modules/iam_policy?ref=v0.1.8"

  name        = "GitHub-Actions-Website-S3-Deployment-Policy"
  description = "A Policy allowing GitHub Actions to deploy the website to the mudmuseum.com S3 bucket with restricted permissions and specified source IP ranges."
  policy      = data.aws_iam_policy_document.iam_policy_document_github_actions.json
}

module "iam_group_github_actions_website" {
  source      = "github.com/mudmuseum/terraform-modules.git//modules/iam_group?ref=v0.1.8"

  name        = "GitHub-Actions-Website-S3-Deployment"
}

module "iam_group_policy_attachment_github_actions_website" {
  source      = "github.com/mudmuseum/terraform-modules.git//modules/iam_group_policy_attachment?ref=v0.1.8"

  group_name  = module.iam_group_github_actions_website.name
  policy_arn  = module.iam_policy_github_actions_website.policy_arn
}
