// +build linux

package init

import (
	"os"
	"os/signal"
	"syscall"
)

func pidOne() error {
	c := make(chan os.Signal, 10)
	signal.Notify(c, syscall.SIGCHLD)

	for range c {
		for {
			if pid, err := syscall.Wait4(-1, nil, syscall.WNOHANG, nil); err != nil || pid <= 0 {
				break
			}
		}
	}

	return nil
}
