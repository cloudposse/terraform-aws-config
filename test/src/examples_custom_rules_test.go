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

func TestExamplesCustomRules(t *testing.T) {
	rng := rand.New(rand.NewSource(time.Now().UnixNano()))
	randID := strconv.Itoa(rng.Intn(100000))
	attributes := []string{randID}

	terraformOptions := &terraform.Options{
		TerraformDir: "../../examples/custom-rules",
		Upgrade:      true,
		VarFiles:     []string{"fixtures.us-east-2.tfvars"},
		Vars: map[string]interface{}{
			"attributes": attributes,
		},
	}
	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	configRecorderID := terraform.Output(t, terraformOptions, "config_recorder_id")
	bucketID := terraform.Output(t, terraformOptions, "storage_bucket_id")

	assert.Equal(t, fmt.Sprintf("eg-ue2-test-%s-config", randID), configRecorderID)
	assert.Equal(t, fmt.Sprintf("eg-ue2-test-%s-aws-config", randID), bucketID)
}
