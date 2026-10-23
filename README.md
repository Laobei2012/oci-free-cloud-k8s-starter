# oci-free-cloud-k8s-starter

This repository is a template for a Kubernetes cluster on the Oracle Cloud (OCI) free tier. It uses the Terraform modules and the Flux apps of [oci-free-cloud-k8s-module](https://github.com/Laobei2012/oci-free-cloud-k8s-module) at one release tag.

A copy of this repository gives you these parts:

1. An OKE cluster in account A, with Terraform stacks for the network, the cluster and Flux.
2. Optional worker nodes in a second free tier account B.
3. Flux, which installs the shared apps of the module and the apps in `gitops/apps`.
4. A GitHub Actions workflow that plans each pull request and applies on `/apply`. It logs in to OCI with OIDC (a signed token per job), so GitHub stores no OCI API key.
5. Renovate, which bumps the module tag in Terraform and in Flux in one pull request.

## Layout

| Path | Content |
| --- | --- |
| [terraform/accounts/a](terraform/accounts/a/) | Account A: the network, the OKE cluster and the node pool |
| [terraform/accounts/b](terraform/accounts/b/) | Only with account B: its network, the peering and its worker nodes |
| [terraform/clusters/oci](terraform/clusters/oci/) | Flux, external-secrets and the Kubernetes roles of the CI users |
| [terraform/github-oidc](terraform/github-oidc/) | The GitHub Actions login of each account. You apply it on your machine |
| [gitops/clusters/oci](gitops/clusters/oci/) | The Flux entry point and `cluster-vars.yaml`, the values of your cluster |
| [gitops/apps](gitops/apps/) | Your own apps |
| [.github/workflows](.github/workflows/) | `terraform.yml` plans and applies. `check.yml` runs checks without OCI |

[terraform/README.md](terraform/README.md) explains the stacks and the CI.

## Prerequisites

You need these accounts and services:

1. One OCI free tier account A, and optionally a second account B.
2. A domain in Cloudflare and an API token for it, for cert-manager and external-dns.
3. A GitHub organization with an OAuth app for Dex and an OAuth app for Teleport.
4. A GitHub App for Flux, and a GitHub token. After step 1 of the first run, install the app on your repository.
5. A Slack app and a channel for the Flux alerts.

The shared apps also read a PagerDuty routing key. If you do not use PagerDuty, store a placeholder value in the vault secret `PAGERDUTY_ROUTING_KEY`.

You need these tools on your machine: Terraform 1.12 or later, the `oci` CLI with a profile for each account in `~/.oci/config`, `kubectl`, `gh` and `jq`. The `DEFAULT` profile is account A. The `account_b` profile is account B.

## First run

You do these steps once, on your machine. Until step 9, the workflow `terraform.yml` skips all jobs, so CI does not apply at the same time as you.

1. Click "Use this template" on GitHub to make your repository. Then clone it.

2. In account A, create the bucket for the Terraform states. Write down the namespace that the second command shows.

   ```
   oci os bucket create --name terraform-states --versioning Enabled --compartment-id <tenancy_id>
   oci os ns get
   ```

3. In account A, create a vault and a key in the OCI console (Identity & Security > Vault). Then create the vault secrets in the [table of the module README](https://github.com/Laobei2012/oci-free-cloud-k8s-module#vault-secrets). [terraform/README.md](terraform/README.md#variables) shows the command.

4. In each stack folder that you use, copy `backend.hcl.example` to `backend.hcl` and `terraform.tfvars.example` to `terraform.tfvars`. Set your values. Each stack runs with these commands:

   ```
   terraform init -backend-config=backend.hcl
   terraform apply
   ```

5. Apply `terraform/github-oidc/a`. Then add the secret `OCI_CLIENT_A` in the same folder:

   ```
   gh secret set OCI_CLIENT_A --body "$(terraform output -json github_oidc | jq -r .client_id):$(terraform output -raw github_oidc_client_secret)"
   ```

6. Apply `terraform/accounts/a`. It writes `terraform/.kube.config`. Set the output `zone_prefix` as `oci_zone_prefix_a` in `gitops/clusters/oci/cluster-vars.yaml`.

7. Set your other values in `cluster-vars.yaml`. Leave `lb_ip` and `lb_security_group_id` for step 8. Commit the `terraform.tfvars` files, `terraform/.kube.config` and `cluster-vars.yaml`, and push them to `main`.

8. Apply `terraform/clusters/oci`. Flux starts and syncs `gitops/clusters/oci` of your repository. If the apply fails on the `ClusterSecretStore`, wait until Flux installs external-secrets, and apply again. Then set the two load balancer values in `cluster-vars.yaml`, and push again:

   ```
   oci network nsg list --compartment-id <compartment_id> --display-name ingress --query 'data[0].id' --raw-output
   kubectl --kubeconfig terraform/.kube.config -n envoy-gateway get service -o wide
   ```

   The first command shows `lb_security_group_id`. When OCI made the load balancer, the second command shows its `EXTERNAL-IP`, which is `lb_ip`.

9. Turn on CI with the repository variables in the next section.

From now on, you change Terraform with a pull request. Read the plan comment, then comment `/apply`, then merge. [terraform/README.md](terraform/README.md#ci) has the details.

## Repository variables and secrets

The workflow reads these values. Set them in the root folder of your repository:

```
gh variable set OCI_REGION_A --body us-phoenix-1
gh variable set OCI_STATE_NAMESPACE --body <namespace>
gh variable set OCI_STATE_BUCKET --body terraform-states
gh variable set OCI_DOMAIN_A --body "$(terraform -chdir=terraform/github-oidc/a output -json github_oidc | jq -r .domain_url)"
gh variable set OCI_TENANCY_A --body <tenancy_id>
```

Set `OCI_TENANCY_A` last, because it turns on the workflow. [terraform/README.md](terraform/README.md#oci-login) has the table of all values.

Only the repository owner can start `/apply`. If an organization owns your repository, change `OWNER` in the job `gate` of `terraform.yml` to `MEMBER`, or to the association of your account.

## Add account B

The stacks of account B keep their state in the bucket of account A.

1. Apply `terraform/github-oidc/b`. In that folder, add the secret `OCI_CLIENT_B` with the command of step 5.
2. Set `account_b_tenancy_id` and `account_b_region` in `terraform/accounts/a`, and apply it.
3. Apply `terraform/accounts/b`. Set its output `rpc_id` or `lpg_id` in `terraform/accounts/a`, and apply `accounts/a` again. The [module README](https://github.com/Laobei2012/oci-free-cloud-k8s-module#one-account-or-two-accounts) explains the peering.
4. Set the output `zone_prefix` of `accounts/b` as `oci_zone_prefix_b` in `cluster-vars.yaml`. Add `platform-account-b.yaml` to `gitops/clusters/oci/kustomization.yaml`.
5. Set the repository variables `OCI_REGION_B`, `OCI_DOMAIN_B` and `OCI_TENANCY_B`.

If you never use account B, you can delete `terraform/accounts/b`, `terraform/github-oidc/b` and `gitops/clusters/oci/platform-account-b.yaml`. The workflow plans only the stacks whose folder exists.

## Update to a new release

Install the [Renovate app](https://github.com/apps/renovate) on your repository. Renovate opens one pull request that changes the module tag in each `main.tf` and in `gitops/clusters/oci/platform-source.yaml`. Keep the two tags the same. Read the release notes of the module before you merge.
