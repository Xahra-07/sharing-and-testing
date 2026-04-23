# =============================================================================
# Input Variables
# =============================================================================
# All configurable parameters for the infrastructure. Sensitive values like
# do_token should be set via environment variables (TF_VAR_do_token), never
# committed to source control.
# =============================================================================

# -----------------------------------------------------------------------------
# Authentication
# -----------------------------------------------------------------------------

variable "do_token" {
  type        = string
  sensitive   = true
  description = "DigitalOcean Personal Access Token. Set via TF_VAR_do_token environment variable."

  validation {
    condition     = length(var.do_token) > 0
    error_message = "The do_token variable must not be empty. Set it via: $env:TF_VAR_do_token = 'your-token'"
  }
}

# -----------------------------------------------------------------------------
# Droplet Configuration
# -----------------------------------------------------------------------------

variable "droplet_name" {
  type        = string
  default     = "terraform-managed"
  description = "Hostname for the droplet."
}

variable "region" {
  type        = string
  default     = "nyc1"
  description = "DigitalOcean datacenter region slug (e.g., nyc1, lon1, ams3, fra1)."
}

variable "droplet_size" {
  type        = string
  default     = "s-2vcpu-2gb"
  description = "Droplet size slug. See: https://slugs.do-api.dev/"
}

variable "droplet_image" {
  type        = string
  default     = "ubuntu-24-04-x64"
  description = "Droplet OS image slug."
}

variable "droplet_monitoring" {
  type        = bool
  default     = true
  description = "Enable DigitalOcean monitoring agent on the droplet."
}

variable "droplet_ipv6" {
  type        = bool
  default     = true
  description = "Enable IPv6 on the droplet."
}

variable "droplet_backups" {
  type        = bool
  default     = false
  description = "Enable weekly backups for the droplet (adds 20% to droplet cost)."
}

# -----------------------------------------------------------------------------
# SSH Key Configuration
# -----------------------------------------------------------------------------

variable "ssh_key_name" {
  type        = string
  default     = "terraform-managed-key"
  description = "Name for the SSH key in DigitalOcean."
}

variable "ssh_pub_key_path" {
  type        = string
  default     = "./keys/do_terraform_ed25519.pub"
  description = "Path to the SSH public key file to upload to DigitalOcean."
}

variable "ssh_private_key_path" {
  type        = string
  default     = "./keys/do_terraform_ed25519"
  description = "Path to the SSH private key file (used in output for SSH command)."
}

# -----------------------------------------------------------------------------
# Project & Tagging
# -----------------------------------------------------------------------------

variable "project_name" {
  type        = string
  default     = "terraform-managed"
  description = "DigitalOcean project name to group resources."
}

variable "project_description" {
  type        = string
  default     = "Infrastructure managed by Terraform"
  description = "Description for the DigitalOcean project."
}

variable "environment" {
  type        = string
  default     = "dev"
  description = "Environment label (dev, staging, production)."

  validation {
    condition     = contains(["dev", "staging", "production"], var.environment)
    error_message = "Environment must be one of: dev, staging, production."
  }
}

variable "tags" {
  type        = list(string)
  default     = []
  description = "Additional tags to apply to the droplet."
}
