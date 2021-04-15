########################
#                      #
#      Setup Tags      #
#                      #
########################

data "aws_region" "current-region" {}

locals {
  tags = {
    "cost-center"        = "mudmuseum"
    "mm:resource-type"   = "aws_ecr_repository"
    "mm:resource-region" = data.aws_region.current-region.name
    "mm:project"         = "pipeline-build-push"
    "mm:environment"     = "persistent"
  }
}

########################################################
#                                                      #
#      Root Module - Elastic Container Repository      #
#                                                      #
########################################################

module "ecr_mudmuseum" {
  source = "github.com/mudmuseum/terraform-modules.git//modules/elastic_container_registry?ref=v0.2.8"

  names  = [ "rom-2.4.b4",
             "dystopiagold",
             "gathering-1.0.1" ]

  tags   = local.tags
}
