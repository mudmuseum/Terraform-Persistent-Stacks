########################
#                      #
#      Setup Tags      #
#                      #
########################

data "aws_region" "current-region" {}

locals {
  tags = {
    "cost-center"        = "mudmuseum"
    "mm:resource-type"   = "aws_s3_bucket"
    "mm:resource-region" = data.aws_region.current-region.name 
    "mm:project"         = "mud host"
    "mm:environment"     = "persistent"
  }
}

############################################
#                                          #
#      Root Module - S3 Backup Bucket      #
#                                          #
############################################

module "s3_backups_mudmuseum" {
  source                = "github.com/mudmuseum/terraform-modules.git//modules/s3?ref=v0.2.3"

  bucket                = "mudmuseum-backups"
  logging_target_prefix = "ec2-backups"

  tags                  = local.tags
}
