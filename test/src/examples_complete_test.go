package test

import (
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	testStructure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
	"k8s.io/apimachinery/pkg/util/runtime"
	"os"
	"strings"
	"testing"
)

func cleanup(t *testing.T, terraformOptions *terraform.Options, tempTestFolder string) {
	terraform.Destroy(t, terraformOptions)
	os.RemoveAll(tempTestFolder)
}

// Test the Terraform module in examples/complete using Terratest.
func TestExamplesComplete(t *testing.T) {
	t.Parallel()
	randID := strings.ToLower(random.UniqueId())
	attributes := []string{randID}

	rootFolder := "../../"
	terraformFolderRelativeToRoot := "examples/complete"
	varFiles := []string{"fixtures.us-east-2.tfvars"}

	tempTestFolder := testStructure.CopyTerraformFolderToTemp(t, rootFolder, terraformFolderRelativeToRoot)

	terraformOptions := &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: tempTestFolder,
		Upgrade:      true,
		// Variables to pass to our Terraform code using -var-file options
		VarFiles: varFiles,
		// We always include a random attribute so that parallel tests
		// and AWS resources do not interfere with each other
		Vars: map[string]interface{}{
			"attributes": attributes,
		},
	}

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer cleanup(t, terraformOptions, tempTestFolder)

	// If Go runtime crushes, run `terraform destroy` to clean up any resources that were created
	defer runtime.HandleCrash(func(i interface{}) {
		cleanup(t, terraformOptions, tempTestFolder)
	})

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)

	// Ideally we would test that the deployment is functional in a way that
	// confirms that the IAM role for the service account is working, but that is too hard, at least for now.
	// Mainly we just test that the `apply` worked without errors.

	// Run `terraform output` to get the value of an output variable
	roleName := terraform.Output(t, terraformOptions, "service_account_role_name")

	// Verify we're getting back the outputs we expect
	// Ensure we get the right IRSA role name
	assert.Equal(t, "eg-ue2-test-helm-"+randID+"-aws-node-termination-handler@test", roleName)
}

// We do not test `enabled = false` for the `helm_release` resource
// because the EKS cluster still needs to exist for the providers to be initialized,
// and for now it is too difficult to isolate the creation of the cluster from the deployment of the Helm release.
// As of this writing, we are not testing `eks-cluster` with `enabled = false` either.
