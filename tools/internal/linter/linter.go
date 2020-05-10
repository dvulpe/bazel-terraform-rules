package main

import (
	"flag"
	"fmt"
	"log"
	"os"
	"os/exec"
	"path/filepath"
)

var (
	TfLintPath    string
	TfLintConfig  string
	TerraformPath string
	Path          string
)

func init() {
	flag.StringVar(&TfLintPath, "tflint", "", "path to tflint")
	flag.StringVar(&TerraformPath, "terraform", "", "path to tflint")
	flag.StringVar(&Path, "path", "", "path to terraform code")
	flag.StringVar(&TfLintConfig, "tflint-config", "", "path to tflint configuration file")
}

func main() {
	flag.Parse()
	fmt.Println("Linting terraform")
	wd, err := os.Getwd()
	if err != nil {
		log.Fatalf("could nnot read directory: %v", err)
	}
	var (
		tf       = filepath.Join(wd, TerraformPath)
		tflint   = filepath.Join(wd, TfLintPath)
		tfmodule = filepath.Join(wd, Path)
		conf     = filepath.Join(wd, TfLintConfig)
	)

	initCmd := exec.Command(tf, "init", "-backend=false")
	initCmd.Dir = tfmodule
	initCmd.Env = environment(wd)
	out, err := initCmd.CombinedOutput()
	if err != nil {
		println(string(out))
		log.Fatalf("could not run terraform init: %v", err)
	}

	lintCmd := exec.Command(tflint, "--config", conf)
	lintCmd.Dir = tfmodule
	lintCmd.Env = environment(wd)
	out, err = lintCmd.CombinedOutput()
	if err != nil {
		println(string(out))
		log.Fatalf("[tflint] failed: %v", err)
	}

	validateCmd := exec.Command(tf, "validate")
	validateCmd.Dir = tfmodule
	validateCmd.Env = environment(wd)
	validateCmd.Stderr = nil
	out, validateErr := validateCmd.CombinedOutput()

	if validateErr != nil {
		println(string(out))
		log.Fatalf("[terraform validate] failed: %v", validateErr)
	}
}

func environment(wd string) []string {
	return append(os.Environ(), fmt.Sprintf("HOME=%s", wd))
}
