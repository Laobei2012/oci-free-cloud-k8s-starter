# Structure
The Terraform code has three stacks. Each stack has its own state. Apply them in this order:

1. [accounts/a](accounts/a/): the network, the peering, the OKE cluster, and node pool A in account A.
2. [accounts/b](accounts/b/): only with account B. The network, the peering, the worker nodes, and the cost reports in account B.
3. [clusters/oci](clusters/oci/): everything that needs the Kubernetes API, for example Flux and external-secrets.

The stacks [github-oidc/a](github-oidc/a/) and [github-oidc/b](github-oidc/b/) hold the GitHub Actions login of account A and account B. You apply them on your machine. [github-oidc/README.md](github-oidc/README.md) explains the login with diagrams.

The split keeps each Terraform run short and keeps the Kubernetes providers out of the account stacks.
Each stack is a thin root module. It holds the providers, the backend, and the variables, and it calls one module from the public repository [oci-free-cloud-k8s-module](https://github.com/Laobei2012/oci-free-cloud-k8s-module) at a release tag.

# CI
The workflow [.github/workflows/terraform.yml](../.github/workflows/terraform.yml) runs Terraform on GitHub Actions:

1. A pull request runs `terraform plan` for each stack whose Terraform files it changes. The plan goes into a PR comment.
2. If the repository owner comments `/apply` on a pull request, GitHub Actions applies the stacks that the pull request changes. If the apply passes, merge the pull request.
3. A push to `main` runs `terraform apply` for each stack that it changes. The applies run one at a time: `accounts/a`, `accounts/b`, and then `clusters/oci`. Each stack reads the outputs of the stacks before it. If one apply fails, the next applies do not run.
4. A manual run (Actions > terraform > Run workflow) runs `plan` or `apply` for one stack.

A bad apply on `accounts/a` can destroy the cluster. Read the plan comment of the PR before you comment `/apply`.

To apply a pull request before you merge it:

1. Rebase the pull request on `main`. If it is behind `main`, `/apply` stops. An apply of an old branch undoes the changes of other merged pull requests.
2. Comment `/apply` on the pull request.
3. Read the comments of the run. Each stack gets the plan that it applies and the result of the apply.
4. If all applies pass, merge the pull request. The merge applies again and finds no changes.

GitHub runs `/apply` with the workflow file of `main`, so a pull request cannot change what `/apply` does. A pull request from a fork cannot use `/apply`.

These files of a stack start a plan: `*.tf`, `*.tfvars`, `.terraform.lock.hcl`, and the files in `files/`. Other changes, for example to a README or to `.github`, start no plan. The script [.github/scripts/changed-stacks.sh](../.github/scripts/changed-stacks.sh) has the rule.

## Status terraform/applied
Each pull request gets the commit status `terraform/applied`:

| State | Meaning |
| --- | --- |
| success | No stack has changes, or `/apply` applied them. |
| pending | A plan has changes. Comment `/apply`. |
| failure | A plan or an apply failed. |

The status does not block the merge. To block the merge, add `terraform/applied` as a required status check of `main` (Settings > Branches). This needs GitHub Pro or a public repository.

Until the repository variable `OCI_TENANCY_A` is set, the job `gate` skips all other jobs. The status is then success with the text "OCI is not set up". A pull request from a fork gets no secrets, so it does not plan either.

## OCI login
GitHub Actions has no OCI API key. The workflow logs in with the OIDC token of the job:

1. [.github/scripts/oci-session.sh](../.github/scripts/oci-session.sh) sends the GitHub token to the token exchange endpoint of the identity domain in account A. If `OCI_TENANCY_B` is set, it does the same in account B.
2. The identity domain gives back a session token (UPST) of a service user. The token expires after about one hour, so the script gets a new token every 15 minutes.
3. A pull request gets the user `github-terraform-plan`, which can only read. The `main` branch gets the user `github-terraform-apply`, which is in the `Administrators` group.

The module [github-oidc](https://github.com/Laobei2012/oci-free-cloud-k8s-module/tree/main/terraform/modules/github-oidc) of the public repository creates the service users, the trust to GitHub and the confidential app `github-terraform` in each account.
The stacks `github-oidc/a` and `github-oidc/b` use the module. The workflow does not plan or apply these stacks, so a CI run cannot break its own login. The plan user also cannot read the trust, because the identity domain gives no read-only access to trusts.
In Kubernetes, `clusters/oci` gives the plan user read access and the apply user `cluster-admin`.

A pull request plans without the state lock, because the plan user cannot write the lock object.

The workflow reads these repository variables and secrets. Each secret is `<client_id>:<client_secret>` of the `github-terraform` app. The values of account B are only for account B. [README.md](../README.md#repository-variables-and-secrets) shows how to set them.

| Name | Kind | Value |
| --- | --- | --- |
| `OCI_REGION_A` | variable | The home region of account A |
| `OCI_TENANCY_A` | variable | The tenancy OCID of account A |
| `OCI_DOMAIN_A` | variable | The output `github_oidc.domain_url` of `github-oidc/a` |
| `OCI_CLIENT_A` | secret | The outputs `github_oidc.client_id` and `github_oidc_client_secret` of `github-oidc/a` |
| `OCI_STATE_NAMESPACE` | variable | The Object Storage namespace of the state bucket |
| `OCI_STATE_BUCKET` | variable | The name of the state bucket |
| `OCI_REGION_B` | variable | The home region of account B |
| `OCI_TENANCY_B` | variable | The tenancy OCID of account B |
| `OCI_DOMAIN_B` | variable | The output `github_oidc.domain_url` of `github-oidc/b` |
| `OCI_CLIENT_B` | secret | The outputs `github_oidc.client_id` and `github_oidc_client_secret` of `github-oidc/b` |

A client secret alone gives no access. The identity domain also needs a GitHub token of this repository.

## First setup
[README.md](../README.md#first-run) has the steps.

# Variables
Each stack has a `terraform.tfvars` file in git, which you copy from `terraform.tfvars.example`. Do not put secrets in it.
The secrets of `clusters/oci` are in the OCI vault `vault_id`, and the module [cluster](https://github.com/Laobei2012/oci-free-cloud-k8s-module/blob/main/terraform/modules/cluster/secrets.tf) reads them:

| Vault secret | Content |
| --- | --- |
| `terraform-gh-token` | The GitHub PAT for FluxCD |
| `terraform-github-app-pem` | The private key of the GitHub App, in PEM format |

To create a secret, run this command with the `compartment_id`, `vault_id` and `vault_key_id` of `clusters/oci/terraform.tfvars`:

```
oci vault secret create-base64 --compartment-id <compartment_id> --vault-id <vault_id> --key-id <vault_key_id> \
  --secret-name terraform-gh-token --secret-content-content "$(printf '%s' '<token>' | base64)"
```

To change a secret, add a new version with `oci vault secret update-base64 --secret-id <id> --secret-content-content ...`.

Commit the file `terraform/.kube.config`, which `accounts/a` writes. It has no credentials, because the `oci` CLI makes the token. If `accounts/a` writes a new version, commit it.
