# Instance / compute VMs
variable "instance_name" {
  description = "Name of the compute instance, keypair, and application credential."
  type        = string
}

variable "image_name" {
  description = "Image name to boot from."
  type        = string
  default     = "NeCTAR Ubuntu 22.04 LTS (Jammy) amd64 (with Docker)"
}

variable "flavor_name" {
  description = "Nova flavor (instance size)."
  type        = string
  default     = "m3.small"
}

variable "network_name" {
  description = "Network to attach to. null = let Nova auto-assign the project's network."
  type        = string
  default     = null
}

variable "extra_ssh_authorized_keys" {
  description = "Optional additional public keys to authorize."
  type        = list(string)
  default     = []
}

# Networking / security groups
variable "ssh_ingress_cidr" {
  description = "CIDR allowed to reach port 22. Required (no default) so a missing value fails at plan instead of silently exposing SSH to 0.0.0.0/0. Use your admin IP as a /32."
  type        = string
}

variable "app_https_cidr" {
  description = "CIDR allowed to reach the app on 443. Public prod = 0.0.0.0/0 (default); private staging = your IP as a /32. Port 80 stays public regardless so Let's Encrypt can issue/renew."
  type        = string
  default     = "0.0.0.0/0"
}

variable "access_network" {
  description = "Name of the attached network whose IP is used for DNS/SSH/public access. QLD allocations attach both 'qld' (routable) and 'qld-data' (internal 10.x) — use 'qld'."
  type        = string
  default     = "qld"
}

# Application / DNS
variable "app_domain" {
  description = "Domain name for app, with trailing dot."
  type        = string
}

variable "target_zone" {
  description = "Existing Designate DNS zone to add the A record into, with trailing dot."
  type        = string
  default     = "nsclc-spatial-atlas.cloud.edu.au."
}

variable "dns_ttl" {
  description = "Time til live (seconds) for the A record."
  type        = number
  default     = 300
}

variable "admin_email" {
  description = "Contact email passed to certbot / Let's Encrypt in cloud-init."
  type        = string
}

variable "swift_container" {
  description = "Swift object-store container holding mosaic.zarr. Prod = \"main\"; a second tier uses its own container."
  type        = string
  default     = "main"
}

variable "app_cred_auth_url" {
  description = "Keystone URL written into the VM's app_credentials.env for the data_store service."
  type        = string
  default     = "https://keystone.rc.nectar.org.au/v3/"
}

# GitHub (prod)
variable "manage_github_secrets" {
  description = "Whether to push SSH key + VM IP to GitHub Actions. true in prod, false in staging."
  type        = bool
  default     = false
}

variable "github_owner" {
  description = "GitHub account/org that owns the repo."
  type        = string
  default     = "clinicalomx"
}

variable "github_repository" {
  description = "Repository to receive the Actions secrets/variables."
  type        = string
  default     = "wtx_viewer_cloud"
}

variable "github_environment" {
  description = "GitHub Environment that holds the deploy secrets and the approval gate."
  type        = string
  default     = "production"
}

variable "github_environment_reviewer_users" {
  description = "GitHub numeric user IDs that may approve a deploy to github_environment. Empty means no approval is required."
  type        = set(number)
  default     = []
}

variable "github_environment_reviewer_teams" {
  description = "GitHub numeric team IDs that may approve a deploy to github_environment. Empty means no approval is required."
  type        = set(number)
  default     = []
}

# State
variable "state_encryption_passphrase" {
  description = "Passphrase for OpenTofu native state encryption."
  type        = string
  sensitive   = true
}
