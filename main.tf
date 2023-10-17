#------------------------------------------------------------------------------
# Enabled API's
#------------------------------------------------------------------------------
resource "google_project_service" "enable_apis" {
  for_each = toset(var.enabled_apis)
  project  = var.project_id

  service            = each.value
  disable_on_destroy = false

  timeouts {
    create = "30m"
    update = "40m"
  }
}

#------------------------------------------------------------------------------
# Service Account
#------------------------------------------------------------------------------
resource "google_service_account" "ci_runner" {
  count = var.create_ci_runner_sa ? 1 : 0

  project      = var.project_id
  account_id   = var.ci_runner_sa_name
  display_name = "CI Runner Service Account"
  description  = "CI Runner Service Account"
}

data "google_service_account" "existing_ci_runner" {
  count      = var.create_ci_runner_sa ? 0 : 1
  project    = var.project_id
  account_id = var.existing_ci_runner_sa_email
}

resource "google_project_iam_member" "ci_runner" {
  for_each = toset(var.ci_runner_sa_roles)

  project = var.project_id
  role    = each.value
  member  = var.create_ci_runner_sa ? "serviceAccount:${google_service_account.ci_runner[0].email}" : "serviceAccount:${data.google_service_account.existing_ci_runner[0].email}"
}


#------------------------------------------------------------------------------
# Terraform Bucket
#------------------------------------------------------------------------------
resource "google_storage_bucket" "terraform" {
  count   = var.create_terraform_bucket ? 1 : 0
  project = var.project_id

  name                        = var.terraform_bucket_name != null ? var.terraform_bucket_name : "${var.project_id}-terraform"
  location                    = var.terraform_bucket_location
  storage_class               = "MULTI_REGIONAL"
  public_access_prevention    = "enforced"
  uniform_bucket_level_access = true
  force_destroy               = var.terraform_prevent_bucket_destroy

  versioning {
    enabled = true
  }
}

data "google_storage_bucket" "existing_terraform" {
  count = (!var.create_terraform_bucket && var.existing_terraform_bucket_name != null) ? 1 : 0
  name  = var.existing_terraform_bucket_name

  depends_on = [
    google_project_service.enable_apis,
  ]
}

resource "google_storage_bucket_iam_member" "terraform" {
  count  = var.create_terraform_bucket || var.existing_terraform_bucket_name != null ? 1 : 0
  bucket = var.create_terraform_bucket ? google_storage_bucket.terraform[0].name : var.existing_terraform_bucket_name
  role   = "roles/storage.objectAdmin"
  member = var.create_ci_runner_sa ? "serviceAccount:${google_service_account.ci_runner[0].email}" : "serviceAccount:${data.google_service_account.existing_ci_runner[0].email}"
}


#------------------------------------------------------------------------------
# Identity pool
#------------------------------------------------------------------------------
module "gh_oidc" {
  source  = "terraform-google-modules/github-actions-runners/google//modules/gh-oidc"
  version = "3.1.2"

  project_id = var.project_id

  pool_id           = var.workload_identity_pool_id
  pool_display_name = var.workload_identity_pool_display_name
  pool_description  = var.workload_identity_pool_description

  provider_id           = var.workload_identity_provider_id
  provider_display_name = var.workload_identity_provider_display_name
  provider_description  = var.workload_identity_provider_description

  sa_mapping = {
    for repo in var.workload_identity_repositories : replace(repo, "/", "-") => {
      sa_name   = google_service_account.ci_runner[0].id
      attribute = "attribute.repository/${repo}"
    }
  }
}
