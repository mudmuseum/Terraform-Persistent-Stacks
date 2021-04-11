module "ecr_mudmuseum" {
  source = "github.com/mudmuseum/terraform-modules.git//modules/elastic_container_registry"

  names  = [ "rom-2.4.b4",
             "dystopiagold" ]
}
