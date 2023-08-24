variable "tempo_app_id" {
  type = string
}

variable "tempo_internal_endpoint" {
  type = string
}

variable "upstream_url" {
  type        = string
  description = "The (internal) upstream URL to proxy to"
  default     = ""
}

variable "ports" {
  type        = list(string)
  description = "The list of ports to open up"
  default     = ["3100"]
}

variable "cf_domain" {
  type        = string
  description = "The CF domain name to use"
}

variable "cf_space_id" {
  type        = string
  description = "The CF Space to deploy in"
}

variable "name_postfix" {
  type        = string
  description = "The postfix string to append to the hostname, prevents namespace clashes"
}

variable "memory" {
  type        = number
  description = "The amount of RAM to allocate for Caddy (MB)"
  default     = 128
}

variable "disk" {
  type        = number
  description = "The amount of Disk space to allocate for Grafana Tempo (MB)"
  default     = 1024
}

variable "docker_username" {
  type        = string
  description = "Docker registry username"
  default     = ""
}

variable "docker_password" {
  type        = string
  description = "Docker registry password"
  default     = ""
}

variable "caddy_image" {
  type        = string
  description = "Caddy server image to use"
  default     = "library/caddy:2.4.5"
}

variable "disable_auth" {
  type        = bool
  description = "Disable auth"
  default     = false
}
