package utils

import (
	"github.com/mitchellh/go-testing-interface"
	"io/ioutil"
	"log"
	"os"
	"path/filepath"
)

func TerraformFinder(t testing.T) string {
	tf, ok := os.LookupEnv("TERRAFORM_EXECUTABLE")
	if ok {
		return tf
	}
	root := rootPath(t, ".", "external", 10)
	return filepath.Join(root, "terraform_toolchain/terraform/terraform")
}

func rootPath(t testing.T, path string, markerFolder string, maxDepth int) string {
	if maxDepth == 0 {
		t.Fatalf("exhausted searches")
	}
	log.Println("traversing directory ", path)
	files, err := ioutil.ReadDir(path)
	if err != nil {
		t.Fatalf("Could not list directory %v: %v", path, err)
	}
	for _, f := range files {
		log.Printf("checking file %v", f.Name())
		if f.IsDir() && f.Name() == markerFolder {
			return filepath.Join(path, f.Name())
		}
	}

	return rootPath(t, filepath.Join(path, ".."), markerFolder, maxDepth-1)
}
