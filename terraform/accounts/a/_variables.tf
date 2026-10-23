variable "oci_config_profile" {
  description = "Profile in ~/.oci/config with the credentials of account A"
  type        = string
  default     = "DEFAULT"
}

variable "oci_auth" {
  description = "Auth type of the account A profile: ApiKey, or SecurityToken for a session token (CI)"
  type        = string
  default     = "ApiKey"
}

variable "compartment_id" {
  type        = string
  description = "The compartment to create the resources in"
}

variable "tenancy_id" {
  type        = string
  description = "The tenancy to create the resources in"
}

variable "region" {
  description = "OCI region"
  type        = string
}

variable "ssh_public_key" {
  description = "SSH Public Key used to access all instances"
  type        = string
}

variable "kubernetes_worker_nodes" {
  description = "Worker node count"
  type        = number

  default = 2
}

variable "node_memory_in_gbs" {
  description = "Memory per worker node in GB"
  type        = number
}

variable "node_ocpus" {
  description = "OCPUs per worker node"
  type        = number
}

variable "node_boot_volume_size_in_gbs" {
  description = "Boot volume size per worker node in GB"
  type        = number
}

variable "group_name" {
  description = "Account A group that runs this terraform. Its OCID is account_a_group_id in terraform/accounts/b"
  type        = string
  default     = "Administrators"
}

variable "account_b_tenancy_id" {
  description = "Tenancy OCID of account B, which hosts the additional worker nodes. Null for a cluster in account A only"
  type        = string
  default     = null
}

variable "account_b_region" {
  description = "Home region of account B. If it is the same as region, the VCNs peer with local peering gateways. Required with account_b_tenancy_id"
  type        = string
  default     = null
}

variable "account_b_rpc_id" {
  description = "RPC OCID of account B (output rpc_id of terraform/accounts/b). Null until terraform/accounts/b exists"
  type        = string
  default     = null
}

variable "account_b_lpg_id" {
  description = "LPG OCID of account B (output lpg_id of terraform/accounts/b). Null until terraform/accounts/b exists"
  type        = string
  default     = null
}

variable "account_b_vcn_cidr" {
  description = "CIDR of the account B VCN. Must not overlap with 10.0.0.0/16"
  type        = string
  default     = "10.1.0.0/16"
}
