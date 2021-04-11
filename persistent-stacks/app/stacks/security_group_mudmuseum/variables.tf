variable "security_group_name" {
  description = "Name of the Security Group."
  default     = "security_group_mudmuseum_com"
}

variable "ec2_ingress_ports" {
  description = "The ingress ports for EC2."
  type        = map
  default     = {
    "22"   = ["89.45.90.32/32"]
    "9000" = ["0.0.0.0/0"]
    "8000" = ["0.0.0.0/0"]
  }
}

variable "vpc_id" {
  description = "The VPC ID."
}
