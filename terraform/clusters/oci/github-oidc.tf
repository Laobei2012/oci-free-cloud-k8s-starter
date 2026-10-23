# Kubernetes access of the GitHub Actions users from terraform/github-oidc/a.
# OKE uses the sub claim of the GitHub token as the Kubernetes user name.

data "terraform_remote_state" "github_oidc_a" {
  backend = "oci"
  config = {
    namespace           = var.state_namespace
    bucket              = var.state_bucket
    key                 = "github-oidc-a/terraform.tfstate"
    config_file_profile = var.oci_config_profile
    auth                = var.oci_auth
    region              = var.region
  }
}

locals {
  github_oidc = data.terraform_remote_state.github_oidc_a.outputs.github_oidc
}

# a plan reads every resource, helm also reads its release secrets
resource "kubernetes_cluster_role_v1" "terraform_plan" {
  metadata {
    name = "github-terraform-plan"
  }

  rule {
    api_groups = ["*"]
    resources  = ["*"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_cluster_role_binding_v1" "terraform_plan" {
  metadata {
    name = "github-terraform-plan"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role_v1.terraform_plan.metadata[0].name
  }

  subject {
    api_group = "rbac.authorization.k8s.io"
    kind      = "User"
    name      = local.github_oidc.plan_subject
  }
}

resource "kubernetes_cluster_role_binding_v1" "terraform_apply" {
  metadata {
    name = "github-terraform-apply"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }

  subject {
    api_group = "rbac.authorization.k8s.io"
    kind      = "User"
    name      = local.github_oidc.apply_subject
  }
}
