########################
#                      #
#      Setup Tags      #
#                      #
########################

locals {
  tags = {
    "cost-center"        = "mudmuseum"
    "mm:resource-region" = "global"
    "mm:project"         = "pipeline-build-push"
    "mm:environment"     = "persistent"
  }
}

data "aws_caller_identity" "current" {}

#####################################
#                                   #
# IAM Policy, Group, and Attachment #
#    for GitHub Actions Website     #
#                                   #
#####################################

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
  source      = "github.com/mudmuseum/terraform-modules.git//modules/iam_policy?ref=v0.2.5"

  name        = "GitHub-Actions-Website-S3-Deployment-Policy"
  description = "A Policy allowing GitHub Actions to deploy the website to the mudmuseum.com S3 bucket with restricted permissions and specified source IP ranges."
  policy      = data.aws_iam_policy_document.iam_policy_document_github_actions.json

  tags        = merge( local.tags, map("mm:resource-type", "aws_iam_policy") )
}

module "iam_group_github_actions_website" {
  source      = "github.com/mudmuseum/terraform-modules.git//modules/iam_group?ref=v0.2.6"

  name        = "GitHub-Actions-Website-S3-Deployment"
}

module "iam_group_policy_attachment_github_actions_website" {
  source      = "github.com/mudmuseum/terraform-modules.git//modules/iam_group_policy_attachment?ref=v0.1.8"

  group_name  = module.iam_group_github_actions_website.name
  policy_arn  = module.iam_policy_github_actions_website.policy_arn
}

#####################################
#                                   #
# IAM Policy, Group, and Attachment #
#    for GitHub Actions ECR Push    #
#                                   #
#####################################

data "aws_iam_policy_document" "iam_policy_document_github_actions_push_ecr" {

  statement {
    actions     = [ "ecr:GetAuthorizationToken" ]
    resources   = [ "*" ]
  }
  statement {
    actions     = [ "ecr:UploadLayerPart",
                    "ecr:UntagResource",
                    "ecr:TagResource",
                    "ecr:StartImageScan",
                    "ecr:PutImage",
                    "ecr:ListTagsForResource",
                    "ecr:ListImages",
                    "ecr:InitiateLayerUpload",
                    "ecr:GetDownloadUrlForLayer",
                    "ecr:DescribeRepositories",
                    "ecr:DescribeImages",
                    "ecr:DescribeImageScanFindings",
                    "ecr:CompleteLayerUpload",
                    "ecr:BatchGetImage",
                    "ecr:BatchCheckLayerAvailability" ]
    resources   = [ "arn:aws:ecr:${var.region}:${data.aws_caller_identity.current.account_id}:repository/*" ]
  }
}

module "iam_policy_github_actions_push_ecr" {
  source      = "github.com/mudmuseum/terraform-modules.git//modules/iam_policy?ref=v0.2.5"

  name        = "GitHub-Actions-ECR-Push-Policy"
  description = "A Policy allowing GitHub Actions to push images to ECR."
  policy      = data.aws_iam_policy_document.iam_policy_document_github_actions_push_ecr.json

  tags        = merge( local.tags, map("mm:resource-type", "aws_iam_policy") )
}

module "iam_group_github_actions_push_ecr" {
  source      = "github.com/mudmuseum/terraform-modules.git//modules/iam_group?ref=v0.2.6"

  name        = "GitHub-Actions-Muds-Push-to-ECR"
}

module "iam_group_policy_attachment_github_actions_push_ecr" {
  source      = "github.com/mudmuseum/terraform-modules.git//modules/iam_group_policy_attachment?ref=v0.1.8"

  group_name  = module.iam_group_github_actions_push_ecr.name
  policy_arn  = module.iam_policy_github_actions_push_ecr.policy_arn
}
