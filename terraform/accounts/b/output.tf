output "node_private_ips" {
  value = module.account_b.node_private_ips
}

# set as account_b_rpc_id in terraform/accounts/a, if the regions differ
output "rpc_id" {
  value = module.account_b.rpc_id
}

# set as account_b_lpg_id in terraform/accounts/a, if the regions are the same
output "lpg_id" {
  value = module.account_b.lpg_id
}

# set as oci_zone_prefix_b in cluster-vars
output "zone_prefix" {
  value = module.account_b.zone_prefix
}
