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
	TerraformPath string
	Path          string
)

func init() {
	flag.StringVar(&TerraformPath, "terraform", "", "path to tflint")
	flag.StringVar(&Path, "path", "", "path to terraform code")
}

func main() {
	flag.Parse()
	fmt.Println("Terraform fmt check\n")
	wd, err := os.Getwd()
	if err != nil {
		log.Fatalf("could nnot read directory: %v", err)
	}
	var (
		tf       = filepath.Join(wd, TerraformPath)
		tfmodule = filepath.Join(wd, Path)
	)
	fmtCheck := exec.Command(tf, "fmt", "-check", "-diff", tfmodule)
	out, err := fmtCheck.CombinedOutput()
	if err != nil {
		fmt.Println("Terraform fmt check failed: please check the diff below:")
		fmt.Println(string(out))
		log.Fatalf("[terraform fmt] failed: %v", err)
	}
	fmt.Println("Terraform format check successful")
}
