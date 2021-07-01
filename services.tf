
resource "cloudfoundry_service_instance" "s3" {
  name  = "tf-s3-tempo-${local.postfix}"
  space = var.cf_space_id
  # TODO: This needs to be driven by the CF region
  //noinspection HILUnresolvedReference
  service_plan = data.cloudfoundry_service.s3.service_plans["US Standard"]
}