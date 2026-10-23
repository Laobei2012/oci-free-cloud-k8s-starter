terraform {
  # the backend values are in backend.hcl, see backend.hcl.example:
  # terraform init -backend-config=backend.hcl
  backend "oci" {}

  required_providers {
    jq = {
      source  = "massdriver-cloud/jq"
      version = "0.2.1"
    }
    oci = {
      source  = "oracle/oci"
      version = "~> 9.1.0"
    }
  }
}
