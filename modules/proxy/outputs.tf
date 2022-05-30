output "proxy_username" {
  value = "tempo"
}

output "proxy_password" {
  description = "The Tempo proxy password. Username is always 'tempo'"
  value       = random_password.proxy_password.result
  sensitive   = true
}

output "proxy_endpoint" {
  description = "The Tempo proxy endpoint"
  value       = cloudfoundry_route.tempo_proxy.endpoint
}
