module "cluster" {
  source = "git::https://github.com/Laobei2012/oci-free-cloud-k8s-module.git//terraform/modules/cluster?ref=v0.1.6"

  compartment_id             = var.compartment_id
  region                     = var.region
  vault_id                   = var.vault_id
  vault_key_id               = var.vault_key_id
  tenancy_id                 = var.tenancy_id
  github_app_id              = var.github_app_id
  github_app_installation_id = var.github_app_installation_id
  email                      = var.email
  gh_org                     = var.gh_org
  gh_repository              = var.gh_repository
  cluster_domain             = var.cluster_domain
}
