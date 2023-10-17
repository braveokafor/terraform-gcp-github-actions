variable "project_id" {
  type        = string
  description = "The ID of the project"
  default     = null
}

variable "enabled_apis" {
  description = "Google Cloud API's to enable on the project."
  type        = list(string)
  default = [
    "compute.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "cloudresourcemanager.googleapis.com",
  ]
}

#------------------------------------------------------------------------------
# CI Runner (IAM)
#------------------------------------------------------------------------------
variable "create_ci_runner_sa" {
  description = "Boolean to decide if a service account should be created"
  default     = true
}

variable "existing_ci_runner_sa_email" {
  description = "Email of the existing service account to be used"
  default     = null
}

variable "ci_runner_sa_name" {
  type        = string
  description = "IAM roles name"
  default     = "ci-runner"
}

variable "ci_runner_sa_roles" {
  type        = list(string)
  description = "IAM roles to assign to the `ci-runner` service account"
  default     = ["roles/owner"]
}


#------------------------------------------------------------------------------
# Terraform bucket (GCS)
#------------------------------------------------------------------------------
variable "create_terraform_bucket" {
  description = "Boolean to decide if a bucket should be created"
  default     = true
}

variable "existing_terraform_bucket_name" {
  description = "Name of the existing bucket to be used"
  default     = null
}

variable "terraform_bucket_name" {
  type        = string
  description = "Globally unique name for the state bucket, defaults to (project-id)-terraform"
  default     = null
}

variable "terraform_bucket_location" {
  type        = string
  description = "Global region to create the bucket, e.g. EU"
  default     = "EU"
}

variable "terraform_prevent_bucket_destroy" {
  type        = bool
  description = "Bucket `force_destroy` value"
  default     = true
}


#------------------------------------------------------------------------------
# Identity pool
#------------------------------------------------------------------------------
variable "workload_identity_pool_id" {
  type        = string
  description = "Workload Identity Pool ID"
  default     = "github"

  validation {
    condition     = substr(var.workload_identity_pool_id, 0, 4) != "gcp-" && length(regex("([a-z0-9-]{4,32})", var.workload_identity_pool_id)) == 1
    error_message = "The pool_id value should be 4-32 characters, and may contain the characters [a-z0-9-]."
  }
}

variable "workload_identity_pool_display_name" {
  type        = string
  description = "Workload Identity Pool display name"
  default     = "Github Pool"
}

variable "workload_identity_pool_description" {
  type        = string
  description = "Workload Identity Pool description"
  default     = "Github Workload Identity Pool managed by Terraform"
}


#------------------------------------------------------------------------------
# Identity pool provider
#------------------------------------------------------------------------------
variable "workload_identity_provider_id" {
  type        = string
  description = "Workload Identity Pool Provider ID"
  default     = "github"

  validation {
    condition     = substr(var.workload_identity_provider_id, 0, 4) != "gcp-" && length(regex("([a-z0-9-]{4,32})", var.workload_identity_provider_id)) == 1
    error_message = "The provider_id value should be 4-32 characters, and may contain the characters [a-z0-9-]."
  }
}

variable "workload_identity_provider_display_name" {
  type        = string
  description = "Workload Identity Pool Provider display name"
  default     = "Github Provider"
}

variable "workload_identity_provider_description" {
  type        = string
  description = "Workload Identity Pool Provider description"
  default     = "Github Workload Identity Pool Provider managed by Terraform"
}

#------------------------------------------------------------------------------
# GitHub repositories
#------------------------------------------------------------------------------
variable "workload_identity_repositories" {
  description = "List of repositories in the '{USER/ORG}/REPO' format: (`braveokafor/healthchecker`)."
  type        = list(string)
  default     = []
}
