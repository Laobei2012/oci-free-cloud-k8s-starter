variable "oci_config_profile" {
  description = "Profile in ~/.oci/config with the credentials of account B"
  type        = string
  default     = "account_b"
}

variable "tenancy_id" {
  description = "Tenancy OCID of account B"
  type        = string
}

variable "region" {
  description = "Home region of account B"
  type        = string
}

variable "repository" {
  description = "Your copy of the starter, as owner/name"
  type        = string
}

variable "subject_prefix" {
  description = "The start of the sub claim of the GitHub token, before ':pull_request'"
  type        = string
}
