# account A, from the matching profile in ~/.oci/config
provider "oci" {
  config_file_profile = var.oci_config_profile
  auth                = var.oci_auth
  region              = var.region
}

provider "kubectl" {
  load_config_file = true
  config_path      = "../../.kube.config"
}

provider "helm" {
  kubernetes = {
    config_path = "../../.kube.config"
  }
}

provider "kubernetes" {
  config_path = "../../.kube.config"
}
