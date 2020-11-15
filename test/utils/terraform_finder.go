package utils

import (
	"github.com/bazelbuild/rules_go/go/tools/bazel"
	"github.com/mitchellh/go-testing-interface"
	"os"
)

func TerraformFinder(t testing.T) string {
	tf, ok := os.LookupEnv("TERRAFORM_EXECUTABLE")
	if ok {
		return tf
	}
	tf, err := bazel.Runfile("external/terraform_toolchain/terraform/terraform")
	if err != nil {
		t.Fatalf("could not find terraform executable: %v", err)
	}
	return tf
}
