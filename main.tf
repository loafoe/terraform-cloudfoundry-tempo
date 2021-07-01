locals {
  postfix       = var.name_postfix != "" ? var.name_postfix : random_id.id.hex
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
  name         = "tempo"
  space        = var.cf_space_id
  memory       = var.memory
  disk_quota   = var.disk
  docker_image = var.tempo_image
  environment  = merge({}, var.environment)

  routes {
    route = cloudfoundry_route.tempo.id
  }
  routes {
    route = cloudfoundry_route.tempo_internal.id
  }

  service_binding {
    service_instance = cloudfoundry_service_instance.s3.id
  }
}

resource "cloudfoundry_route" "tempo" {
  domain   = data.cloudfoundry_domain.domain.id
  space    = var.cf_space_id
  hostname = "tempo-${local.postfix}"
}

resource "cloudfoundry_route" "tempo_internal" {
  domain   = data.cloudfoundry_domain.internal.id
  space    = var.cf_space_id
  hostname = "tempo-${local.postfix}"
}

resource "cloudfoundry_network_policy" "tempo" {
  count = length(var.network_policies) > 0 ? 1 : 0

  dynamic "policy" {
    for_each = [for p in var.network_policies : {
      destination_app = p.destination_app
      port            = p.port
      protocol        = p.protocol
    }]
    content {
      source_app      = cloudfoundry_app.tempo.id
      destination_app = policy.value.destination_app
      protocol        = policy.value.protocol == "" ? "tcp" : policy.value.protocol
      port            = policy.value.port
    }
  }
}
