locals {
  postfix = var.name_postfix != "" ? var.name_postfix : random_id.id.hex
}

resource "random_id" "id" {
  byte_length = 8
}

data "cloudfoundry_service" "s3" {
  name = var.s3_broker_settings.service_broker
}

data "cloudfoundry_domain" "domain" {
  name = var.cf_domain
}

data "cloudfoundry_domain" "internal" {
  name = "apps.internal"
}

resource "cloudfoundry_app" "tempo" {
  name         = "tf-tempo-${local.postfix}"
  space        = var.cf_space_id
  memory       = var.memory
  disk_quota   = var.disk
  docker_image = var.tempo_image
  environment  = merge({}, var.environment)

  //noinspection HCLUnknownBlockType
  routes {
    route = cloudfoundry_route.tempo_internal.id
  }

  //noinspection HCLUnknownBlockType
  service_binding {
    service_instance = cloudfoundry_service_instance.s3.id
  }

  labels = {
    "variant.tva/exporter" = true,
  }
  annotations = {
    "prometheus.exporter.type" = "tempo_exporter"
    "prometheus.exporter.port" = "3100"
    "prometheus.exporter.path" = "/metrics"
  }
}

resource "cloudfoundry_route" "tempo" {
  count = var.enable_public_proxy ? 1 : 0

  domain   = data.cloudfoundry_domain.domain.id
  space    = var.cf_space_id
  hostname = "tf-tempo-${local.postfix}"
}

resource "cloudfoundry_route" "tempo_internal" {
  domain   = data.cloudfoundry_domain.internal.id
  space    = var.cf_space_id
  hostname = "tf-tempo-${local.postfix}"
}

resource "cloudfoundry_network_policy" "tempo" {
  count = length(var.network_policies) > 0 ? 1 : 0

  dynamic "policy" {
    for_each = [for p in var.network_policies : {
      //noinspection HILUnresolvedReference
      destination_app = p.destination_app
      //noinspection HILUnresolvedReference
      port = p.port
      //noinspection HILUnresolvedReference
      protocol = p.protocol
    }]
    content {
      source_app      = cloudfoundry_app.tempo.id
      destination_app = policy.value.destination_app
      protocol        = policy.value.protocol == "" ? "tcp" : policy.value.protocol
      port            = policy.value.port
    }
  }
}

module "proxy" {
  count  = var.enable_public_proxy ? 1 : 0
  source = "./modules/proxy"


  tempo_app_id            = cloudfoundry_app.tempo.id
  tempo_internal_endpoint = cloudfoundry_route.tempo_internal.endpoint
  name_postfix            = local.postfix
  cf_domain               = var.cf_domain
  cf_space_id             = var.cf_space_id
}
