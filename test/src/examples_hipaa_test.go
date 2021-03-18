package test

import (
	"fmt"
	"math/rand"
	"strconv"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

// Test the Terraform module in examples/complete using Terratest.
func TestExamplesHipaa(t *testing.T) {
	t.Parallel()

	rand.Seed(time.Now().UnixNano())
	randID := strconv.Itoa(rand.Intn(100000))
	attributes := []string{randID}

	terraformOptions := &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: "../../examples/hipaa",
		Upgrade:      true,
		// Variables to pass to our Terraform code using -var-file options
		VarFiles: []string{"fixtures.us-east-2.tfvars"},
		// We always include a random attribute so that parallel tests
		// and AWS resources do not interfere with each other
		Vars: map[string]interface{}{
			"attributes": attributes,
		},
	}
	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer terraform.Destroy(t, terraformOptions)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)

	// Run `terraform output` to get the value of an output variable
	configRecorderID := terraform.Output(t, terraformOptions, "config_recorder_id")
	bucketID := terraform.Output(t, terraformOptions, "storage_bucket_id")
	conformancePackArn := terraform.Output(t, terraformOptions, "conformance_pack_arn")

	// Ensure we get the attribute included in the IDs
	assert.Equal(t, fmt.Sprintf("eg-ue2-test-%s-config", randID), configRecorderID)
	assert.Equal(t, fmt.Sprintf("eg-ue2-test-%s-aws-config", randID), bucketID)
	assert.NotEqual(t, nil, conformancePackArn)
}
