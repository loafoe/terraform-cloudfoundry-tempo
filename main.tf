data "cloudfoundry_org" "org" {
  name = var.cf_org
}
data "cloudfoundry_space" "space" {
  org  = data.cloudfoundry_org.org.id
  name = var.cf_space
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
  space        = data.cloudfoundry_space.space.id
  memory       = var.memory
  disk_quota   = var.disk
  docker_image = var.tempo_image
  environment = merge({}, var.environment)
  command = "/tempo -config.file=/etc/tempo.yaml"

  routes {
    route = cloudfoundry_route.tempo.id
  }
  routes {
    route = cloudfoundry_route.tempo_internal.id
  }
}

resource "cloudfoundry_app" "tempo_query" {
  name = "tempo-query"
  space        = data.cloudfoundry_space.space.id
  memory       = var.memory
  disk_quota   = var.disk
  docker_image = var.tempo_query_image
  environment = merge({}, var.environment)
  command = "/go/bin/query-linux --grpc-storage-plugin.configuration-file=/etc/tempo-query.yaml"

  routes {
    route = cloudfoundry_route.tempo_query.id
  }
}

resource "cloudfoundry_route" "tempo" {
  domain   = data.cloudfoundry_domain.domain.id
  space    = data.cloudfoundry_space.space.id
  hostname = var.name_postfix == "" ? "tempo" : "tempo-${var.name_postfix}"
}

resource "cloudfoundry_route" "tempo_internal" {
  domain = data.cloudfoundry_domain.internal.id
  space = data.cloudfoundry_space.space.id
  hostname = var.name_postfix == "" ? "tempo" : "tempo-${var.name_postfix}"
}

resource "cloudfoundry_route" "tempo_query" {
  domain   = data.cloudfoundry_domain.domain.id
  space    = data.cloudfoundry_space.space.id
  hostname = var.name_postfix == "" ? "tempo-query" : "tempo-query-${var.name_postfix}"
}

resource "cloudfoundry_network_policy" "tempo_query" {
  policy {
    source_app      = cloudfoundry_app.tempo_query.id
    destination_app = cloudfoundry_app.tempo.id
    port            = "3100"
  }
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
