module "vpc" {
  source                             = "github.com/mudmuseum/terraform-modules.git//modules/vpc"

  cidr_block                         = "10.0.0.0/16"
  tag_name                           = "MudMuseum VPC."
}

module "public_subnet" {
  source                             = "github.com/mudmuseum/terraform-modules.git//modules/subnet"

  vpc_id                             = module.vpc.vpc_id
  public_subnet_cidr_block           = "10.0.0.0/24"
  public_subnet_availability_zone    = "us-east-1a"
  public_subnet_tag_name             = "MudMuseum Public Subnet."
}

module "internet_gateway" {
  source                             = "github.com/mudmuseum/terraform-modules.git//modules/internet_gateway?ref=v0.0.1"

  vpc_id                             = module.vpc.vpc_id
  internet_gateway_tag_name          = "MudMuseum Internet Gateway."
}

module "public_route_table" {
  source                             = "github.com/mudmuseum/terraform-modules.git//modules/route_table?ref=v0.0.2"

  vpc_id                             = module.vpc.vpc_id
  route_table_public_cidr_block      = "0.0.0.0/0"
  route_table_ipv6_public_cidr_block = "::/0"
  internet_gateway_id                = module.internet_gateway.id
  route_table_tag_name               = "MudMuseum Routing Table."
}

module "public_route_association" {
  source                             = "github.com/mudmuseum/terraform-modules.git//modules/route_table_association?ref=v0.0.2"

  public_subnet_id                   = module.public_subnet.public_subnet_id
  route_table_public_route_id        = module.public_route_table.public_route_table_id
}
