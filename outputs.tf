output "tempo_endpoint" {
  description = "The endpoint where Tempo is reachable on"
  value       = cloudfoundry_route.tempo.endpoint
}

output "tempo_id" {
  description = "The Tempo apps' id"
  value       = cloudfoundry_app.tempo.id
}
