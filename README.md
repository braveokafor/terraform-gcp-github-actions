# terraform-gcp-github-actions

[![Build Status][badge_build_status]][link_build_status]
[![Release Status][badge_release_status]][link_build_status]
[![Issues][badge_issues]][link_issues]
[![Issues][badge_pulls]][link_pulls]
[![Version][badge_release_version]][link_release_version]

Terraform module to set up [Workload Identity](https://cloud.google.com/blog/products/identity-security/secure-your-use-of-third-party-tools-with-identity-federation) in Google Cloud to securely connect GitHub Actions with Google Cloud services.  
Includes configurations for APIs, service accounts, identity pools and providers, and management of [terraform state buckets](https://developer.hashicorp.com/terraform/language/settings/backends/gcs).

### Features
- **Workload Identity for GitHub Actions:** The main functionality, where a Workload Identity pool and provider are created, and necessary IAM roles are assigned for GitHub Actions.
- **Enabled APIs:** Enables necessary Google Cloud APIs in the project.
- **Service Account:** Conditionally creates a service account or uses an existing one and assigns specified IAM roles.
- **Google Cloud Storage (GCS) Bucket:** Conditionally creates a GCS bucket or uses an existing one, managing IAM permissions and other configurations such as versioning and public access prevention.

## Usage

The module outputs `workload_identity_provider_name` which can be used to configure GitHub action workflows.  

```yaml
name: Terraform CI

on:
  push:
    branches:
      - "main"

permissions:
  contents: read
  id-token: write

env:
  GOOGLE_SERVICE_ACCOUNT: ${{ secrets.GOOGLE_SERVICE_ACCOUNT }} # output.ci_runner_sa_email | "ci-runner@YOUR_GCP_PROJECT_ID.iam.gserviceaccount.com"
  GOOGLE_WORKLOAD_IDENTITY_PROVIDER: ${{ secrets.GOOGLE_WORKLOAD_IDENTITY_PROVIDER }} # output.workload_identity_provider_name | "projects/YOUR_GCP_PROJECT_NUMBER/locations/global/workloadIdentityPools/github/providers/github"

jobs:
  terraform:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v3

      - name: Authenticate to Google Cloud
        id: "auth"
        uses: "google-github-actions/auth@v1"
        with:
          service_account: ${{ env.GOOGLE_SERVICE_ACCOUNT }}
          workload_identity_provider: ${{ env.GOOGLE_WORKLOAD_IDENTITY_PROVIDER }}
          access_token_lifetime: 300s
```


The module outputs `generated_backend_file` which can be used to configure GCS remote state.  
This will be disabled if `var.create_terraform_bucket = false` and `var.existing_terraform_bucket_name = false`

```hcl
module "github_actions_workload_identity" {
  source = "git::https://github.com/braveokafor/terraform-gcp-github-actions.git//.?ref=v0.2.0"

  project_id                     = "YOUR_GCP_PROJECT_ID"
  enabled_apis                   = ["compute.googleapis.com", "iam.googleapis.com"]
  create_ci_runner_sa            = true
  ci_runner_sa_roles             = ["roles/owner"]
  create_terraform_bucket        = true
  workload_identity_pool_id      = "github-pool"
  workload_identity_provider_id  = "github-provider"
  workload_identity_repositories = ["braveokafor/terraform-gcp-github-actions"]
}
```

Once resources are created, you can configure your terraform files to use the GCS backend as follows.

```hcl
terraform {
  backend "gcs" {
    bucket = "YOUR_GCP_PROJECT_ID_TERRAFORM"
    prefix = "tf-state"
  }
}
```

`YOUR_GCP_PROJECT_ID_TERRAFORM` can be replaced by `terraform_bucket_name` in outputs from this module.

See [the official document](https://developer.hashicorp.com/terraform/language/settings/backends/gcs#example-configuration) for more detail.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13 |
| <a name="requirement_google"></a> [google](#requirement\_google) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | ~> 4.0 |

## Inputs

| Name | Description | Type | Required |
|------|-------------|------|:--------:|
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The ID of the project | `string` | yes |
| <a name="input_ci_runner_sa_name"></a> [ci\_runner\_sa\_name](#input\_ci\_runner\_sa\_name) | IAM roles name | `string` | no |
| <a name="input_ci_runner_sa_roles"></a> [ci\_runner\_sa\_roles](#input\_ci\_runner\_sa\_roles) | IAM roles to assign to the `ci-runner` service account | `list(string)` | no |
| <a name="input_create_ci_runner_sa"></a> [create\_ci\_runner\_sa](#input\_create\_ci\_runner\_sa) | Boolean to decide if a service account should be created | `bool` | no |
| <a name="input_create_terraform_bucket"></a> [create\_terraform\_bucket](#input\_create\_terraform\_bucket) | Boolean to decide if a bucket should be created | `bool` | no |
| <a name="input_enabled_apis"></a> [enabled\_apis](#input\_enabled\_apis) | Google Cloud API's to enable on the project. | `list(string)` | no |
| <a name="input_existing_ci_runner_sa_email"></a> [existing\_ci\_runner\_sa\_email](#input\_existing\_ci\_runner\_sa\_email) | Email of the existing service account to be used | `any` | no |
| <a name="input_existing_terraform_bucket_name"></a> [existing\_terraform\_bucket\_name](#input\_existing\_terraform\_bucket\_name) | Name of the existing bucket to be used | `any` | no |
| <a name="input_terraform_bucket_location"></a> [terraform\_bucket\_location](#input\_terraform\_bucket\_location) | Global region to create the bucket, e.g. EU | `string` | no |
| <a name="input_terraform_bucket_name"></a> [terraform\_bucket\_name](#input\_terraform\_bucket\_name) | Globally unique name for the state bucket, defaults to (project-id)-terraform | `string` | no |
| <a name="input_terraform_prevent_bucket_destroy"></a> [terraform\_prevent\_bucket\_destroy](#input\_terraform\_prevent\_bucket\_destroy) | Bucket `force_destroy` value | `bool` | no |
| <a name="input_workload_identity_pool_description"></a> [workload\_identity\_pool\_description](#input\_workload\_identity\_pool\_description) | Workload Identity Pool description | `string` | no |
| <a name="input_workload_identity_pool_display_name"></a> [workload\_identity\_pool\_display\_name](#input\_workload\_identity\_pool\_display\_name) | Workload Identity Pool display name | `string` | no |
| <a name="input_workload_identity_pool_id"></a> [workload\_identity\_pool\_id](#input\_workload\_identity\_pool\_id) | Workload Identity Pool ID | `string` | no |
| <a name="input_workload_identity_provider_description"></a> [workload\_identity\_provider\_description](#input\_workload\_identity\_provider\_description) | Workload Identity Pool Provider description | `string` | no |
| <a name="input_workload_identity_provider_display_name"></a> [workload\_identity\_provider\_display\_name](#input\_workload\_identity\_provider\_display\_name) | Workload Identity Pool Provider display name | `string` | no |
| <a name="input_workload_identity_provider_id"></a> [workload\_identity\_provider\_id](#input\_workload\_identity\_provider\_id) | Workload Identity Pool Provider ID | `string` | no |
| <a name="input_workload_identity_repositories"></a> [workload\_identity\_repositories](#input\_workload\_identity\_repositories) | List of repositories in the '{USER/ORG}/REPO' format: (`braveokafor/healthchecker`). | `list(string)` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ci_runner_sa_email"></a> [ci\_runner\_sa\_email](#output\_ci\_runner\_sa\_email) | CI runner service account email |
| <a name="output_generated_backend_file"></a> [generated\_backend\_file](#output\_generated\_backend\_file) | Generated `backend.tf` |
| <a name="output_terraform_bucket_name"></a> [terraform\_bucket\_name](#output\_terraform\_bucket\_name) | Terraform bucket name |
| <a name="output_workload_identity_pool_name"></a> [workload\_identity\_pool\_name](#output\_workload\_identity\_pool\_name) | Workload identity pool name |
| <a name="output_workload_identity_provider_name"></a> [workload\_identity\_provider\_name](#output\_workload\_identity\_provider\_name) | Workload identity provider name |
<!-- END_TF_DOCS -->   

[link_issues]:https://github.com/braveokafor/terraform-gcp-github-actions/issues
[link_pulls]:https://github.com/braveokafor/terraform-gcp-github-actions/pulls
[link_build_status]:https://github.com/braveokafor/terraform-gcp-github-actions/actions/workflows/terraform-ci.yaml
[link_release_status]:https://github.com/braveokafor/terraform-gcp-github-actions/actions/workflows/terraform-release.yaml
[link_release_version]:https://github.com/braveokafor/terraform-gcp-github-actions/releases/latest

[badge_issues]:https://img.shields.io/github/issues-raw/braveokafor/terraform-gcp-github-actions?style=flat-square&logo=GitHub
[badge_pulls]:https://img.shields.io/github/issues-pr/braveokafor/terraform-gcp-github-actions?style=flat-square&logo=GitHub
[badge_build_status]:https://img.shields.io/github/actions/workflow/status/braveokafor/terraform-gcp-github-actions/terraform-ci.yaml?style=flat-square&logo=GitHub&label=build
[badge_release_status]:https://img.shields.io/github/actions/workflow/status/braveokafor/terraform-gcp-github-actions/terraform-release.yaml?style=flat-square&logo=GitHub&label=release
[badge_release_version]:https://img.shields.io/github/v/release/braveokafor/terraform-gcp-github-actions?style=flat-square&logo=GitHub&label=version
