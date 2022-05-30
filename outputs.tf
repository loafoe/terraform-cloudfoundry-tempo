output "tempo_proxy_endpoint" {
  description = "The endpoint where Tempo is reachable on"
  value       = module.proxy.*.proxy_endpoint
}

output "tempo_proxy_username" {
  description = "The endpoint where Tempo is reachable on"
  value       = module.proxy.*.proxy_username
  sensitive   = true
}

output "tempo_proxy_password" {
  description = "The endpoint where Tempo is reachable on"
  value       = module.proxy.*.proxy_password
  sensitive   = true
}

output "tempo_internal_endpoint" {
  description = "The internal endpoint where Tempo is reachable on"
  value       = cloudfoundry_route.tempo_internal.endpoint
}

output "tempo_app_id" {
  description = "The Tempo apps' id"
  value       = cloudfoundry_app.tempo.id
}
