# The GitHub Actions login of account A. The workflow does not plan or apply this
# stack, so a CI run cannot break its own login. Run it on your machine.
terraform {
  # the backend values are in backend.hcl, see backend.hcl.example:
  # terraform init -backend-config=backend.hcl
  backend "oci" {}

  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 9.1.0"
    }
  }
}
