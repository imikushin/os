package util

import (
	"strings"
)

func GetValue(index int, args []string) (string, bool) {
	val := args[index]
	parts := strings.SplitN(val, "=", 2)
	if len(parts) == 1 {
		if len(args) > index+1 {
			return args[index+1], true
		} else {
			return "", false
		}
	} else {
		return parts[1], false
	}
}
