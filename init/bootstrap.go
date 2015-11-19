package init

import (
	"os"
	"os/exec"
	"syscall"

	"fmt"
	"strings"

	log "github.com/Sirupsen/logrus"
	"github.com/docker/libcompose/project"
	"github.com/rancher/os/compose"
	"github.com/rancher/os/config"
	"github.com/rancher/os/util"
)

func autoformat(cfg *config.CloudConfig) (*config.CloudConfig, error) {
	if len(cfg.Rancher.State.Autoformat) == 0 || util.ResolveDevice(cfg.Rancher.State.Dev) != "" {
		return cfg, nil
	}
	AUTOFORMAT := "AUTOFORMAT=" + strings.Join(cfg.Rancher.State.Autoformat, " ")
	FORMATZERO := "FORMATZERO=" + fmt.Sprint(cfg.Rancher.State.FormatZero)
	t := *cfg
	t.Rancher.Autoformat["autoformat"].Environment = project.NewMaporEqualSlice([]string{AUTOFORMAT, FORMATZERO})
	log.Info("Running Autoformat services")
	_, err := compose.RunServiceSet("autoformat", &t, t.Rancher.Autoformat)
	return &t, err
}

func runBootstrapContainers(cfg *config.CloudConfig) (*config.CloudConfig, error) {
	log.Info("Running Bootstrap services")
	_, err := compose.RunServiceSet("bootstrap", cfg, cfg.Rancher.BootstrapContainers)
	return cfg, err
}

func startDocker(cfg *config.CloudConfig) (chan interface{}, error) {

	args := getLaunchArgs(cfg, &cfg.Rancher.BootstrapDocker, nil)

	cmd := exec.Command(config.DOCKERLAUNCH_BIN, args)
	cmd.Env = &cfg.Rancher.BootstrapDocker.Environment

	if err := cmd.Start(); err != nil {
		return nil, err
	}

	c := make(chan interface{})
	go func() {
		<-c
		cmd.Process.Signal(syscall.SIGTERM)
		cmd.Wait()
		c <- struct{}{}
	}()

	return c, nil
}

func stopDocker(c chan interface{}) error {
	c <- struct{}{}
	<-c

	return os.RemoveAll(config.DOCKER_SYSTEM_HOME)
}

func bootstrap(cfg *config.CloudConfig) error {
	log.Info("Launching Bootstrap Docker")
	c, err := startDocker(cfg)
	if err != nil {
		return err
	}

	defer stopDocker(c)

	_, err = config.ChainCfgFuncs(cfg,
		loadImages,
		runBootstrapContainers,
		autoformat)
	return err
}
