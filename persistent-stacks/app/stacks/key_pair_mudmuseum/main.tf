########################
#                      #
#      Setup Tags      #
#                      #
########################

data "aws_region" "current-region" {}

locals {
  tags = {
    "cost-center"        = "mudmuseum"
    "mm:resource-type"   = "aws_key_pair"
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

module "key_pair_ec2_mudmuseum_com" {
  source     = "github.com/mudmuseum/terraform-modules.git//modules/key_pair?ref=v0.2.7"

  key_name   = "ec2_mudmuseum_com"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDEAfJdkXFGhIn9kxRba/n8Cn+XRhCWtuXMTe5rYAmr6zPeJRAPR0aheYOHndfypK6RpmpyoVGarp80FMWI8lFOQ5alTcas2UnV9AfKAMsbJbXfpqW0jpiE4SMLZBUUjWbh2RZGGkGsvzk+QmjtMhmiSykYqjmEBXT3B7NERt41BdQxh4J1zazySfXN4uA8RrfXa4Y9M+flQxMyBJQRbWmXVEQldRtU6VAySV6AutiZybyXm4RRXxBcWYocYf3kc58xXNYMMPEDm1sUczoDP7JGSJvRIW9DvWEgNmFXAcruPp+ryu2Nt8wIR7zisZKzx+s1o41wzJRh1n7/fNa09R7UDtoFh0RVGZhDjROMEULhyD4uUCw06B2eXie25Fc+HpmSWfrIv/mXh1xFzeHP4JJb6HDL4+OG4lHCBuW5zuh22c/GTjchxox7uuzqSPK036g0NxIj6O1b8tRezyfqAz3Vgr55UpQLx1ccV2UDQCupt6wfJJRuMJwCMYy4a19SsOCy/RL5QI+NVpKzVyaghtqBVI7FQG8wG4w3re3CvP3xv9Qj1gzkJxSdhlN+wyxPy45AGTQpLST4WQ1A19/lkQeTf0LwKQtopOdlqYHE0sjP+d1t8oit0noUI8dogR0OFbTrLmaQ5/KXbMzk5qNkoXFwdotz7PKUdqN5bR3YoOa07Q=="

  tags       = local.tags
}
