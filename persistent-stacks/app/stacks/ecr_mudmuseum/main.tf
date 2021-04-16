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
  source       = "github.com/mudmuseum/terraform-modules.git//modules/elastic_container_registry?ref=v0.2.11"

#  names        = [ "rom-2.4.b4",
#                   "dystopiagold",
#                   "gathering-1.0.1" ]

  repositories = [ 
                   { 
                     name: "rom-2.4.b4"
                     tags: merge(local.tags, map("port", "8000", "mud-name", "ROM 2.4b4") ) 
                   },
                   {
                     name: "dystopiagold"
                     tags: merge(local.tags, map("port", "9000", "mud-name", "Dystopia Gold") )
                   },
                   {
                     name: "gathering-1.0.1"
                     tags: merge(local.tags, map("port", "9000", "mud-name", "The Gathering 1.0.1") )
                   }
                 ]
}
