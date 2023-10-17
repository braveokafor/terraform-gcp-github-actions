#------------------------------------------------------------------------------
# CI Runner (IAM)
#------------------------------------------------------------------------------
output "ci_runner_sa_email" {
  description = "CI runner service account email"
  value       = var.create_ci_runner_sa ? google_service_account.ci_runner[0].email : data.google_service_account.existing_ci_runner[0].email
}


#------------------------------------------------------------------------------
# Terraform bucket (GCS)
#------------------------------------------------------------------------------
output "terraform_bucket_name" {
  description = "Terraform bucket name"
  value       = var.create_terraform_bucket ? google_storage_bucket.terraform[0].name : (var.existing_terraform_bucket_name != null ? data.google_storage_bucket.existing_terraform[0].name : null)
}


#------------------------------------------------------------------------------
# Workload Identity
#------------------------------------------------------------------------------
output "workload_identity_pool_name" {
  description = "Workload identity pool name"
  value       = module.gh_oidc.pool_name
}

output "workload_identity_provider_name" {
  description = "Workload identity provider name"
  value       = module.gh_oidc.provider_name
}


#------------------------------------------------------------------------------
# Generated `backend.tf`
#------------------------------------------------------------------------------
output "generated_backend_file" {
  description = "Generated `backend.tf`"
  value       = <<EOF
%{if var.create_terraform_bucket || var.existing_terraform_bucket_name != null~}
terraform {
  backend "gcs" {
      bucket      = "${var.create_terraform_bucket ? google_storage_bucket.terraform[0].name : data.google_storage_bucket.existing_terraform[0].name}"
      prefix      = "tf-state"
  }
}
%{endif~}
EOF
}
