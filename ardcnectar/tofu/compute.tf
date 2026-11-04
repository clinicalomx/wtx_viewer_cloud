locals {
  # Designate names carry a trailing dot; the HTTP URL / cert CN must not.
  app_fqdn = trimsuffix(var.app_domain, ".")

  # qld vs qld-data ip, retrieve qld 
  vm_ip = one([
    for n in openstack_compute_instance_v2.viewer.network :
    n.fixed_ip_v4 if n.name == var.access_network
  ])
}

resource "tls_private_key" "deploy" {
  algorithm = "ED25519"
}

resource "openstack_compute_keypair_v2" "deploy" {
  name       = var.instance_name
  public_key = tls_private_key.deploy.public_key_openssh
}

data "openstack_images_image_v2" "base" {
  name        = var.image_name
  most_recent = true
}

data "openstack_compute_flavor_v2" "base" {
  name = var.flavor_name
}

# Compute instance
resource "openstack_compute_instance_v2" "viewer" {
  name      = var.instance_name
  image_id  = data.openstack_images_image_v2.base.id
  flavor_id = data.openstack_compute_flavor_v2.base.id
  key_pair  = openstack_compute_keypair_v2.deploy.name

  security_groups = [
    "default",
    openstack_networking_secgroup_v2.app.name,
  ]

  # auto-assign the project network
  dynamic "network" {
    for_each = var.network_name == null ? [] : [var.network_name]
    content {
      name = network.value
    }
  }

  # rendered cloud-init. env vars injected 
  user_data = templatefile("${path.module}/cloud_init.yaml.tftpl", {
    os_auth_url       = var.app_cred_auth_url
    os_project_id     = data.openstack_identity_auth_scope_v3.current.project_id
    app_cred_id       = openstack_identity_application_credential_v3.app.id
    app_cred_secret   = openstack_identity_application_credential_v3.app.secret
    app_domain        = local.app_fqdn
    admin_email       = var.admin_email
    ssh_public_keys   = var.extra_ssh_authorized_keys
    swift_container   = var.swift_container
    github_owner      = var.github_owner
    github_repository = var.github_repository
  })

  # cd keeps this updated. 
  lifecycle {
    ignore_changes = [user_data]
  }
}
