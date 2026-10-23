terraform {
  # the backend values are in backend.hcl, see backend.hcl.example:
  # terraform init -backend-config=backend.hcl
  backend "oci" {}

  required_providers {
    oci = {
      source = "oracle/oci"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1"
    }

    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.0.0"
    }

    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.0.0"
    }
  }
}
