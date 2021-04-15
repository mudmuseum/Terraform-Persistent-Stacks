########################
#                      #
#      Setup Tags      #
#                      #
########################

data "aws_region" "current-region" {}

locals {
  tags = {
    "cost-center"        = "mudmuseum"
    "mm:resource-region" = data.aws_region.current-region.name
    "mm:project"         = "mud host"
    "mm:environment"     = "persistent"
  }
}

############################################
#                                          #
#      Root Module - VPC & Friends         #
#                                          #
############################################

module "vpc" {
  source                             = "github.com/mudmuseum/terraform-modules.git//modules/vpc?ref=v0.2.1"

  cidr_block                         = "10.0.0.0/16"
  tags                               = merge( local.tags, map("mm:resource-type", "aws_vpc", "Name", "MudMuseum VPC") )
}

module "public_subnet" {
  source                             = "github.com/mudmuseum/terraform-modules.git//modules/subnet?ref=v0.2.1"

  vpc_id                             = module.vpc.vpc_id
  public_subnet_cidr_block           = "10.0.0.0/24"
  public_subnet_availability_zone    = "us-east-1a"

  tags                               = merge( local.tags, map("mm:resource-type", "aws_subnet", "Name", "MudMuseum Subnet") )
}

module "internet_gateway" {
  source                             = "github.com/mudmuseum/terraform-modules.git//modules/internet_gateway?ref=v0.2.1"

  vpc_id                             = module.vpc.vpc_id

  tags                               = merge( local.tags, map("mm:resource-type", "aws_internet_gateway", "Name", "MudMuseum Internet Gateway") )
}

module "public_route_table" {
  source                             = "github.com/mudmuseum/terraform-modules.git//modules/route_table?ref=v0.2.1"

  vpc_id                             = module.vpc.vpc_id
  route_table_public_cidr_block      = "0.0.0.0/0"
  route_table_ipv6_public_cidr_block = "::/0"
  internet_gateway_id                = module.internet_gateway.id

  tags                               = merge( local.tags, map("mm:resource-type", "aws_route_table", "Name", "MudMuseum Route Table") )
}

module "public_route_association" {
  source                             = "github.com/mudmuseum/terraform-modules.git//modules/route_table_association?ref=v0.2.1"

  public_subnet_id                   = module.public_subnet.public_subnet_id
  route_table_public_route_id        = module.public_route_table.public_route_table_id
}
