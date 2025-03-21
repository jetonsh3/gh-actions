package main

import (
	"fmt"
	"time"
)

func main() {
	fmt.Println("gh-actions")

	count := 1
	for {
		time.Sleep(1 * time.Second)
		fmt.Println(count)
		count++
	}
}
