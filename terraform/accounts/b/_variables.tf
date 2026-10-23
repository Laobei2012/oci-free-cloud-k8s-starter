variable "oci_config_profile" {
  description = "Profile in ~/.oci/config with the credentials of account B"
  type        = string
  default     = "account_b"
}

variable "oci_auth" {
  description = "Auth type of the account B profile: ApiKey, or SecurityToken for a profile from 'oci session authenticate'"
  type        = string
  default     = "ApiKey"
}

variable "account_a_config_profile" {
  description = "Profile in ~/.oci/config with the credentials of account A, which holds the terraform state"
  type        = string
  default     = "DEFAULT"
}

variable "account_a_auth" {
  description = "Auth type of the account A profile: ApiKey, or SecurityToken for a session token (CI)"
  type        = string
  default     = "ApiKey"
}

variable "account_a_region" {
  description = "Home region of account A, where the terraform state bucket is"
  type        = string
}

variable "tenancy_id" {
  description = "Tenancy OCID of account B"
  type        = string
}

variable "compartment_id" {
  description = "The account B compartment to create the resources in"
  type        = string
}

variable "region" {
  description = "Home region of account B"
  type        = string
}

variable "ssh_public_key" {
  description = "SSH Public Key used to access all instances"
  type        = string
}

variable "vcn_cidr" {
  description = "CIDR of the account B VCN. Must match account_b_vcn_cidr in terraform/accounts/a"
  type        = string
  default     = "10.1.0.0/16"
}

variable "account_a_tenancy_id" {
  description = "Tenancy OCID of account A, which hosts the OKE cluster"
  type        = string
}

variable "account_a_group_id" {
  description = "OCID of the account A group that runs terraform in terraform/accounts/a (group_name there)"
  type        = string
}

variable "account_a_vcn_cidr" {
  description = "CIDR of the k8s VCN in account A"
  type        = string
  default     = "10.0.0.0/16"
}

variable "worker_nodes" {
  description = "Worker node count"
  type        = number
  default     = 2
}

variable "node_memory_in_gbs" {
  description = "Memory per worker node in GB"
  type        = number
  default     = 12
}

variable "node_ocpus" {
  description = "OCPUs per worker node"
  type        = number
  default     = 2
}

variable "node_boot_volume_size_in_gbs" {
  description = "Boot volume size per worker node in GB"
  type        = number
  default     = 75
}

variable "state_namespace" {
  description = "Object Storage namespace of the state bucket in account A, the same as in backend.hcl"
  type        = string
}

variable "state_bucket" {
  description = "State bucket in account A, the same as in backend.hcl"
  type        = string
  default     = "terraform-states"
}
