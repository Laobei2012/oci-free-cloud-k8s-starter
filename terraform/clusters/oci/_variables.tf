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

variable "region" {
  description = "OCI region"
  type        = string
}

variable "vault_id" {
  description = "OCI Vault OIDC"
  type        = string
}

variable "vault_key_id" {
  description = "OCI Vault encryption key OCID"
  type        = string
  default     = null
}

variable "tenancy_id" {
  description = "Tenancy OCID"
  type        = string
}

variable "github_app_id" {
  description = "GitHub App ID"
  type        = string
}

variable "github_app_installation_id" {
  description = "GitHub App Installation ID"
  type        = string
}

variable "email" {
  type        = string
  description = "email"
}

variable "gh_org" {
  description = "The GitHub owner of your copy of the starter"
  type        = string
}

variable "gh_repository" {
  description = "The name of your copy of the starter. Flux syncs gitops/clusters/oci from it"
  type        = string
}

variable "cluster_domain" {
  type        = string
  description = "Base domain of the cluster. Must match cluster_domain in gitops/clusters/oci/cluster-vars.yaml"
}

variable "state_namespace" {
  description = "Object Storage namespace of the terraform state bucket, the namespace value in backend.hcl"
  type        = string
}

variable "state_bucket" {
  description = "Name of the terraform state bucket, the bucket value in backend.hcl"
  type        = string
  default     = "terraform-states"
}
