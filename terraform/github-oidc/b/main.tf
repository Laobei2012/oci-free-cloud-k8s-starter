# see .github/workflows/terraform.yml
module "github_oidc" {
  source = "git::https://github.com/Laobei2012/oci-free-cloud-k8s-module.git//terraform/modules/github-oidc?ref=v0.1.6"

  tenancy_id     = var.tenancy_id
  repository     = var.repository
  subject_prefix = var.subject_prefix
  plan_permissions = [
    "read all-resources in tenancy",
  ]
}

output "github_oidc" {
  value = {
    domain_url    = module.github_oidc.domain_url
    client_id     = module.github_oidc.client_id
    plan_user_id  = module.github_oidc.plan_user_id
    apply_user_id = module.github_oidc.apply_user_id
    plan_subject  = module.github_oidc.plan_subject
    apply_subject = module.github_oidc.apply_subject
  }
}

# the GitHub secret OCI_CLIENT_B is "<client_id>:<this>"
output "github_oidc_client_secret" {
  value     = module.github_oidc.client_secret
  sensitive = true
}
