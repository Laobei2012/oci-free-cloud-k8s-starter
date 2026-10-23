# terraform/accounts/b reads these outputs from the state
output "k8s_cluster_id" {
  value = module.account_a.k8s_cluster_id
}

output "compartment_id" {
  value = module.account_a.compartment_id
}

output "public_subnet_id" {
  value = module.account_a.public_subnet_id
}

output "node_pool_id" {
  value = module.account_a.node_pool_id
}

output "k8s_version" {
  value = module.account_a.k8s_version
}

output "k8s_private_endpoint" {
  value = module.account_a.k8s_private_endpoint
}

output "k8s_cluster_ca" {
  value = module.account_a.k8s_cluster_ca
}

output "account_b_peering_status" {
  value = module.account_a.account_b_peering_status
}

# set as oci_zone_prefix_a in cluster-vars
output "zone_prefix" {
  value = module.account_a.zone_prefix
}
