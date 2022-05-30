resource "random_password" "proxy_password" {
  length  = 32
  special = false
}

resource "random_password" "proxy_password_salt" {
  length = 8
}


resource "htpasswd_password" "hash" {
  password = random_password.proxy_password.result
  salt     = random_password.proxy_password_salt.result
}

resource "cloudfoundry_app" "tempo_proxy" {
  name         = "tf-tempo-proxy-${var.name_postfix}"
  space        = var.cf_space_id
  memory       = 128
  disk_quota   = 512
  docker_image = var.caddy_image
  docker_credentials = {
    username = var.docker_username
    password = var.docker_password
  }

  environment = merge({
    CADDYFILE_BASE64 = base64encode(templatefile("${path.module}/templates/Caddyfile", {
      upstream_url = "http://${var.tempo_internal_endpoint}:3100"
      username     = "tempo"
      password     = base64encode(htpasswd_password.hash.bcrypt)
    }))
  }, {})

  command           = "echo $CADDYFILE_BASE64 | base64 -d > /etc/caddy/Caddyfile && cat /etc/caddy/Caddyfile && caddy run -config /etc/caddy/Caddyfile"
  health_check_type = "process"

  //noinspection HCLUnknownBlockType
  routes {
    route = cloudfoundry_route.tempo_proxy.id
  }
}

resource "cloudfoundry_route" "tempo_proxy" {
  domain   = data.cloudfoundry_domain.domain.id
  space    = var.cf_space_id
  hostname = "tf-tempo-${var.name_postfix}"
}

resource "cloudfoundry_network_policy" "tempo_proxy" {

  policy {
    source_app      = cloudfoundry_app.tempo_proxy.id
    destination_app = var.tempo_app_id
    protocol        = "tcp"
    port            = "3100"
  }
}
