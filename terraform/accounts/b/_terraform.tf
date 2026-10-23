terraform {
  # the backend values are in backend.hcl, see backend.hcl.example:
  # terraform init -backend-config=backend.hcl
  backend "oci" {}

  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 9.1.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0.0"
    }
  }
}
