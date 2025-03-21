package main

import (
	"fmt"
	"gh-actions/internal/version"
	"time"
)

func main() {
	fmt.Println("gh-actions", version.Version)

	count := 1
	for {
		time.Sleep(1 * time.Second)
		fmt.Println(count)
		count++
	}
}
