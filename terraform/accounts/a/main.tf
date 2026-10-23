module "account_a" {
  source = "git::https://github.com/Laobei2012/oci-free-cloud-k8s-module.git//terraform/modules/account-a?ref=v0.1.6"

  oci_config_profile           = var.oci_config_profile
  kubeconfig_path              = "../../.kube.config"
  compartment_id               = var.compartment_id
  tenancy_id                   = var.tenancy_id
  region                       = var.region
  ssh_public_key               = var.ssh_public_key
  kubernetes_worker_nodes      = var.kubernetes_worker_nodes
  node_memory_in_gbs           = var.node_memory_in_gbs
  node_ocpus                   = var.node_ocpus
  node_boot_volume_size_in_gbs = var.node_boot_volume_size_in_gbs
  group_name                   = var.group_name
  account_b_tenancy_id         = var.account_b_tenancy_id
  account_b_region             = var.account_b_region
  account_b_rpc_id             = var.account_b_rpc_id
  account_b_lpg_id             = var.account_b_lpg_id
  account_b_vcn_cidr           = var.account_b_vcn_cidr
}
