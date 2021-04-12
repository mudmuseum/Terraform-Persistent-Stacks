module "route53_zone" {
  source                        = "github.com/mudmuseum/terraform-modules.git//modules/route53_zone?ref=v0.1.5"

  route53_zone_name             = "mudmuseum.com"
}
