# =============================================================================
# Outputs
# =============================================================================
# These values are displayed after `terraform apply` completes. The SSH
# command output lets you immediately connect to the server without any
# additional key configuration.
# =============================================================================

output "droplet_ip" {
  value       = digitalocean_droplet.server.ipv4_address
  description = "Public IPv4 address of the droplet."
}

output "droplet_ipv6" {
  value       = digitalocean_droplet.server.ipv6_address
  description = "Public IPv6 address of the droplet."
}

output "droplet_id" {
  value       = digitalocean_droplet.server.id
  description = "DigitalOcean droplet ID."
}

output "droplet_urn" {
  value       = digitalocean_droplet.server.urn
  description = "DigitalOcean droplet URN."
}

output "droplet_region" {
  value       = digitalocean_droplet.server.region
  description = "Region where the droplet is deployed."
}

output "droplet_price_monthly" {
  value       = digitalocean_droplet.server.price_monthly
  description = "Monthly cost of the droplet in USD."
}

output "ssh_command" {
  value       = "ssh -i ${var.ssh_private_key_path} root@${digitalocean_droplet.server.ipv4_address}"
  description = "Ready-to-use SSH command to connect to the droplet."
}

output "ssh_key_fingerprint" {
  value       = digitalocean_ssh_key.default.fingerprint
  description = "Fingerprint of the SSH key uploaded to DigitalOcean."
}

output "firewall_id" {
  value       = digitalocean_firewall.server.id
  description = "DigitalOcean firewall ID."
}

output "project_id" {
  value       = digitalocean_project.project.id
  description = "DigitalOcean project ID."
}
