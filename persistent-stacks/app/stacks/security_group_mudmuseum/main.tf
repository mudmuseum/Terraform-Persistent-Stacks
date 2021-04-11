module "security-group-mudmuseum_com" {
  source              = "github.com/mudmuseum/terraform-modules.git//modules/security_group"

  security_group_name = var.security_group_name
  ec2_ingress_ports   = var.ec2_ingress_ports
  vpc_id              = var.vpc_id
}
