package constants_test

import (
	"github.com/gruntwork-io/terratest/modules/terraform"
	"testing"
	"tfmodules/test/utils"
)

func TestConstants(t *testing.T) {
	terraformOptions := &terraform.Options{
		TerraformBinary: utils.TerraformFinder(t),
		TerraformDir:    "../../examples/constants",
		EnvVars: map[string]string{
			"HOME": "/tmp", // otherwise terraform blows up
		},
	}
	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)
	expected := "test_value"
	actual := terraform.Output(t, terraformOptions, "test_constant")
	if expected != actual {
		t.Errorf("Expected %v, got %v", expected, actual)
	}
}
