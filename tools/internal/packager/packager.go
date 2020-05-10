package main

import (
	"bufio"
	"flag"
	"fmt"
	"log"
	"os"
)

var ManifestFile string

func init() {
	flag.StringVar(&ManifestFile, "manifest", "", "A manifest of files to be archived")
}

func main() {
	flag.Parse()
	fmt.Printf("Archiving files from manifest\n")
	m, err := os.Open(ManifestFile)
	if err != nil {
		log.Fatalf("could not open manifest: %v", err)
	}
	defer m.Close()

	var files []string
	scanner := bufio.NewScanner(m)
	for scanner.Scan() {
		fmt.Printf("adding %v\n", scanner.Text())
		files = append(files, scanner.Text())
	}
}
