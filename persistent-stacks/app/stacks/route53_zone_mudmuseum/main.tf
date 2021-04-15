########################
#                      #
#      Setup Tags      #
#                      #
########################

locals {
  tags = {
    "cost-center"        = "mudmuseum"
    "mm:resource-type"   = "aws_route53_zone"
    "mm:resource-region" = "global"
    "mm:project"         = "dns"
    "mm:environment"     = "persistent"
  }
}

############################################
#                                          #
#        Root Module - Route53 Zone        #
#                                          #
############################################

module "route53_zone" {
  source            = "github.com/mudmuseum/terraform-modules.git//modules/route53_zone?ref=v0.2.4"

  route53_zone_name = "mudmuseum.com"

  tags              = local.tags
}
