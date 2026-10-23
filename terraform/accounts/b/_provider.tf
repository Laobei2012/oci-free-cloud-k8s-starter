# account B, from the matching profile in ~/.oci/config
provider "oci" {
  config_file_profile = var.oci_config_profile
  auth                = var.oci_auth
  region              = var.region
}

provider "kubernetes" {
  config_path = "../../.kube.config"
}

# outputs of terraform/accounts/a (account A)
data "terraform_remote_state" "infra" {
  backend = "oci"
  config = {
    namespace           = var.state_namespace
    bucket              = var.state_bucket
    key                 = "account-a/terraform.tfstate"
    config_file_profile = var.account_a_config_profile
    auth                = var.account_a_auth
    region              = var.account_a_region
  }
}
