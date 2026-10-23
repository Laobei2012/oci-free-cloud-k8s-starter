module "account_b" {
  source = "git::https://github.com/Laobei2012/oci-free-cloud-k8s-module.git//terraform/modules/account-b?ref=v0.1.6"

  k8s_version                  = data.terraform_remote_state.infra.outputs.k8s_version
  k8s_private_endpoint         = data.terraform_remote_state.infra.outputs.k8s_private_endpoint
  k8s_cluster_ca               = data.terraform_remote_state.infra.outputs.k8s_cluster_ca
  tenancy_id                   = var.tenancy_id
  compartment_id               = var.compartment_id
  region                       = var.region
  ssh_public_key               = var.ssh_public_key
  vcn_cidr                     = var.vcn_cidr
  account_a_tenancy_id         = var.account_a_tenancy_id
  account_a_region             = var.account_a_region
  account_a_group_id           = var.account_a_group_id
  account_a_vcn_cidr           = var.account_a_vcn_cidr
  worker_nodes                 = var.worker_nodes
  node_memory_in_gbs           = var.node_memory_in_gbs
  node_ocpus                   = var.node_ocpus
  node_boot_volume_size_in_gbs = var.node_boot_volume_size_in_gbs
}
