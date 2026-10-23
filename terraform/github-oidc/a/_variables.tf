variable "oci_config_profile" {
  description = "Profile in ~/.oci/config with the credentials of account A"
  type        = string
  default     = "DEFAULT"
}

variable "tenancy_id" {
  description = "Tenancy OCID of account A"
  type        = string
}

variable "region" {
  description = "Home region of account A"
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
