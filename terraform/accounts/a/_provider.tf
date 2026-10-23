# account A, from the matching profile in ~/.oci/config
provider "oci" {
  config_file_profile = var.oci_config_profile
  auth                = var.oci_auth
  region              = var.region
}
