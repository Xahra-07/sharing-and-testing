# =============================================================================
# Terraform & Provider Configuration
# =============================================================================
# This file configures the Terraform version constraint and the DigitalOcean
# provider. The DO token is supplied via the TF_VAR_do_token environment
# variable — never hardcode secrets in source files.
# =============================================================================

terraform {
  required_version = ">= 1.0"

  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.84"
    }
  }

  # -------------------------------------------------------------------------
  # Remote Backend (Optional — uncomment to use DigitalOcean Spaces or S3)
  # -------------------------------------------------------------------------
  # backend "s3" {
  #   endpoints = {
  #     s3 = "https://nyc3.digitaloceanspaces.com"
  #   }
  #   bucket                      = "your-terraform-state-bucket"
  #   key                         = "terraform.tfstate"
  #   region                      = "us-east-1"  # Required but unused by DO Spaces
  #   skip_credentials_validation = true
  #   skip_metadata_api_check     = true
  #   skip_requesting_account_id  = true
  #   skip_s3_checksum            = true
  # }
}

provider "digitalocean" {
  token = var.do_token
}
