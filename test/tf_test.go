//go:build gcp
// +build gcp

package test

import (
	"fmt"
	"os"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/gcp"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestTerraform(t *testing.T) {
	t.Parallel()

	terraformDir := "../"

	// Get the Project Id to use
	projectId := gcp.GetGoogleProjectIDFromEnvVar(t)

	// Generate a single unique identifier for reuse
	randomSuffix := strings.ToLower(random.UniqueId())

	// Define unique identifiers for the resources using the updated names
	ciRunnerSaName := fmt.Sprintf("ci-runner-sa-%s", randomSuffix)
	terraformBucketName := fmt.Sprintf("terraform-bucket-%s", randomSuffix)
	workloadIdentityPoolId := fmt.Sprintf("github-%s", randomSuffix)
	workload_identity_repository := os.Getenv("WORKLOAD_IDENTITY_REPOSITORY")

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: terraformDir,

		// Variables to pass to our Terraform code using -var options
		Vars: map[string]interface{}{
			"project_id":                     projectId,
			"ci_runner_sa_name":              ciRunnerSaName,
			"terraform_bucket_name":          terraformBucketName,
			"workload_identity_pool_id":      workloadIdentityPoolId,
			"workload_identity_repositories": []string{workload_identity_repository},
		},

		EnvVars: map[string]string{
			"GOOGLE_CLOUD_PROJECT": projectId,
		},
	})

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer terraform.Destroy(t, terraformOptions)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)

	// Run `terraform output` to get the values of output variables
	bucketName := terraform.Output(t, terraformOptions, "terraform_bucket_name")
	serviceAccountEmail := terraform.Output(t, terraformOptions, "ci_runner_sa_email")
	workloadIdentityPoolName := terraform.Output(t, terraformOptions, "workload_identity_pool_name")

	// Verify that the storage bucket exists
	gcp.AssertStorageBucketExists(t, bucketName)

	// Verify that the service account exists
	assert.True(t, strings.Contains(serviceAccountEmail, "@"), "Output ci_runner_sa_email does not contain '@'")

	// Verify that the workload identity pool exists
	assert.NotEmpty(t, workloadIdentityPoolName, "Output workload_identity_pool_name is empty")
}
