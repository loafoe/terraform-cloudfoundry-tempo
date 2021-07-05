module "tempo" {
  source = "../../"

  cf_domain   = data.hsdp_config.cf.domain
  cf_space_id = "test"
}

data "hsdp_config" "cf" {
  service = "cf"
}