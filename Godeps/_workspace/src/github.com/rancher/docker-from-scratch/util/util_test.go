package util

import (
	"testing"

	"github.com/stretchr/testify/require"
)

func TestNoPanic(t *testing.T) {
	assert := require.New(t)
	args := []string{"daemon", "--log-opt", "max-size=25m", "--log-opt", "max-file=2", "-s", "overlay", "-G", "docker", "-H", "unix:///var/run/docker.sock", "--userland-proxy=false", "--tlsverify", "--tlscacert=ca.pem", "--tlscert=server-cert.pem", "--tlskey=server-key.pem", "-H=0.0.0.0:2376"}
	for i, v := range args {
		if v == "-H=0.0.0.0:2376" {
			val, s := GetValue(i, args)
			assert.Equal("0.0.0.0:2376", val)
			assert.False(s)
		}
		if v == "-H" {
			val, s := GetValue(i, args)
			assert.Equal("unix:///var/run/docker.sock", val)
			assert.True(s)
		}
	}
}
