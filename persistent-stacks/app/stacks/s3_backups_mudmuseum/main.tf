module "s3_backups_mudmuseum" {
  source                = "github.com/mudmuseum/terraform-modules.git//modules/s3?ref=v0.1.8"

  bucket                = "mudmuseum-backups"
  logging_target_prefix = "ec2-backups"
}
