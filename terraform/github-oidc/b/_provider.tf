# account B, from the matching profile in ~/.oci/config
provider "oci" {
  config_file_profile = var.oci_config_profile
  region              = var.region
}
