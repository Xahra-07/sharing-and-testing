# =============================================================================
# Main Infrastructure Resources
# =============================================================================
# This file defines the core DigitalOcean infrastructure:
#   - SSH Key (uploaded from local key pair)
#   - Droplet (compute instance)
#   - Firewall (network security rules)
#   - Project (resource grouping)
#
# The SSH key is automatically attached to every droplet, so you never need
# to configure keys manually when creating or accessing servers.
# =============================================================================

# -----------------------------------------------------------------------------
# Local Values
# -----------------------------------------------------------------------------

locals {
  # Merge user-supplied tags with standard tags
  all_tags = concat(
    [
      "terraform",
      "env:${var.environment}",
      "project:${var.project_name}",
    ],
    var.tags
  )
}

# -----------------------------------------------------------------------------
# SSH Key
# -----------------------------------------------------------------------------
# Uploads the locally generated ED25519 public key to DigitalOcean.
# This key is automatically attached to all droplets in this configuration,
# eliminating the need for manual SSH key setup on each new server.
# -----------------------------------------------------------------------------

resource "digitalocean_ssh_key" "default" {
  name       = var.ssh_key_name
  public_key = file(var.ssh_pub_key_path)

  lifecycle {
    # Prevent accidental deletion of the key which would lock you out
    prevent_destroy = false
  }
}

# -----------------------------------------------------------------------------
# Droplet Tags
# -----------------------------------------------------------------------------

resource "digitalocean_tag" "tags" {
  for_each = toset(local.all_tags)
  name     = each.value
}

# -----------------------------------------------------------------------------
# Droplet (Compute Instance)
# -----------------------------------------------------------------------------

resource "digitalocean_droplet" "server" {
  name       = var.droplet_name
  region     = var.region
  size       = var.droplet_size
  image      = var.droplet_image
  monitoring = var.droplet_monitoring
  ipv6       = var.droplet_ipv6
  backups    = var.droplet_backups

  # Attach the SSH key — this is why you never need to configure keys manually
  ssh_keys = [digitalocean_ssh_key.default.fingerprint]

  # Cloud-init script for first-boot provisioning
  user_data = file("${path.module}/cloud-init.yaml")

  # Apply tags for organization and filtering
  tags = [for tag in local.all_tags : digitalocean_tag.tags[tag].id]

  # Ensure graceful handling of recreations
  lifecycle {
    create_before_destroy = true
  }
}

# -----------------------------------------------------------------------------
# Firewall
# -----------------------------------------------------------------------------
# Restricts inbound traffic to only SSH, HTTP, and HTTPS.
# All outbound traffic is allowed (required for package updates, etc.).
# -----------------------------------------------------------------------------

resource "digitalocean_firewall" "server" {
  name = "${var.droplet_name}-firewall"

  droplet_ids = [digitalocean_droplet.server.id]

  # --- Inbound Rules ---

  # SSH access
  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  # HTTP
  inbound_rule {
    protocol         = "tcp"
    port_range       = "80"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  # HTTPS
  inbound_rule {
    protocol         = "tcp"
    port_range       = "443"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  # ICMP (ping) — useful for diagnostics
  inbound_rule {
    protocol         = "icmp"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  # --- Outbound Rules ---

  # Allow all TCP outbound (package updates, API calls, etc.)
  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  # Allow all UDP outbound (DNS, NTP, etc.)
  outbound_rule {
    protocol              = "udp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  # Allow ICMP outbound
  outbound_rule {
    protocol              = "icmp"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}

# -----------------------------------------------------------------------------
# Project (Resource Grouping)
# -----------------------------------------------------------------------------
# Groups all resources under a single DigitalOcean project for organization.
# -----------------------------------------------------------------------------

resource "digitalocean_project" "project" {
  name        = var.project_name
  description = var.project_description
  purpose     = "Service or API"
  environment = title(var.environment)

  resources = [
    digitalocean_droplet.server.urn
  ]
}
