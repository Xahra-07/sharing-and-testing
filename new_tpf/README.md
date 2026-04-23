# DigitalOcean Infrastructure as Code (Terraform)

Terraform configuration to provision and manage DigitalOcean infrastructure. Includes automatic SSH key management — you never need to configure keys manually when creating or accessing servers.

## What Gets Created

| Resource | Details |
|---|---|
| **Droplet** | `s-2vcpu-2gb` (2 vCPUs, 2GB RAM, 60GB disk) on Ubuntu 24.04 in `nyc1` |
| **SSH Key** | ED25519 key pair uploaded to DigitalOcean, auto-attached to all droplets |
| **Firewall** | Allows SSH (22), HTTP (80), HTTPS (443) inbound; all outbound |
| **Project** | Groups all resources for organization |
| **Cloud-Init** | Auto-installs Docker, configures UFW, fail2ban, and SSH hardening |

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.0 installed
- A [DigitalOcean account](https://cloud.digitalocean.com/registrations/new)
- A DigitalOcean **Personal Access Token** (PAT) with read+write scope
  - Generate at: **DigitalOcean Dashboard → API → Tokens → Generate New Token**

## Quick Start

### 1. Set Your DigitalOcean API Token

**PowerShell:**
```powershell
$env:TF_VAR_do_token = "dop_v1_your_token_here"
```

**Bash / Zsh:**
```bash
export TF_VAR_do_token="dop_v1_your_token_here"
```

> ⚠️ **Never hardcode your token in `.tf` or `.tfvars` files.**

### 2. Initialize Terraform

```bash
terraform init
```

### 3. Preview Changes

```bash
terraform plan
```

### 4. Apply (Create Infrastructure)

```bash
terraform apply
```

Type `yes` when prompted. After completion, Terraform outputs the SSH command.

### 5. Connect to Your Server

Use the outputted SSH command directly:

```bash
# The exact command is shown in terraform output
terraform output -raw ssh_command
```

Or manually:

```bash
ssh -i ./keys/do_terraform_ed25519 root@<droplet-ip>
```

> **Note:** The server reboots once after first boot (cloud-init). Wait ~2-3 minutes after `apply` before connecting.

## Common Operations

### View All Outputs
```bash
terraform output
```

### Destroy Infrastructure
```bash
terraform destroy
```

### Update Infrastructure
Edit `terraform.tfvars`, then:
```bash
terraform plan    # Preview changes
terraform apply   # Apply changes
```

## File Structure

```
new_tpf/
├── main.tf              # Core resources (droplet, SSH key, firewall, project)
├── providers.tf         # Terraform & provider configuration
├── variables.tf         # Input variable definitions with defaults
├── outputs.tf           # Output values (IP, SSH command, etc.)
├── terraform.tfvars     # Your variable overrides (gitignored)
├── cloud-init.yaml      # Server bootstrap script (Docker, security)
├── keys/                # SSH key pair (gitignored)
│   ├── do_terraform_ed25519       # Private key
│   └── do_terraform_ed25519.pub   # Public key
├── .gitignore           # Terraform & security gitignore
└── README.md            # This file
```

## Security Notes

- **API token**: Set via environment variable, never in files
- **SSH key**: ED25519, private key gitignored, only public key uploaded to DO
- **Firewall**: Inbound restricted to SSH/HTTP/HTTPS only
- **fail2ban**: Protects against SSH brute-force (3 attempts → 1hr ban)
- **SSH hardening**: Password auth disabled, key-only root login
- **State file**: Gitignored to prevent secret exposure

## Customization

Edit `terraform.tfvars` to change:
- `region` — datacenter location
- `droplet_size` — server resources
- `droplet_image` — operating system
- `environment` — `dev`, `staging`, or `production`
- `droplet_backups` — enable weekly backups (+20% cost)
