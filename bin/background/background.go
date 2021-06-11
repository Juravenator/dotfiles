package main

import (
	"flag"
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"os/exec"
	"os/signal"
	"strconv"
	"syscall"
	"time"
)

func main() {
	period := flag.Int("period", 60, "amount of seconds to wait")
	pidFile := flag.String("pid-file", "/tmp/background.pid", "location of PID file")
	flag.Parse()

	existingProcess := getExistingProcess(*pidFile)
	if existingProcess != nil {
		log.Println("another instance already running, sending HUP and exiting.")
		err := existingProcess.Signal(os.Signal(syscall.SIGHUP))
		if err != nil {
			log.Fatal("unable to send HUP")
		}
		return
	}

	err := writePid(*pidFile)
	if err != nil {
		if err.Error() == "already running" {
			log.Println("already running daemon, just runnin")
		}
		log.Fatal("could not write PID: ", err)
	}
	fehOnHUP()
	go func() {
		for {
			feh()
			time.Sleep(time.Duration(*period) * time.Second)
		}
	}()
	<-make(chan bool)
}

func feh() {
	log.Println("running feh")
	c := exec.Command("/bin/sh", "-c", "feh --randomize --bg-fill ~/Pictures/wallpapers/*")
	err := c.Run()
	log.Println("feh command completed", err)
}

func fehOnHUP() {
	channel := make(chan os.Signal, 1)
	signal.Notify(channel, os.Signal(syscall.SIGHUP))

	go func() {
		for {
			<-channel
			log.Println("SIGHUP received")
			feh()
		}
	}()
}

func writePid(location string) error {
	pid := fmt.Sprintf("%d", os.Getpid())
	return ioutil.WriteFile(location, []byte(pid), 0644)
}

func getExistingProcess(location string) *os.Process {
	_, err := os.Stat(location)
	if os.IsNotExist(err) {
		return nil
	}

	pidBytes, err := ioutil.ReadFile(location)
	if err != nil {
		// when pid file exists but unable to read...
		// Choose between your script silently failing forever, or running twice but maybe fixing the pid file
		// I pick the latter
		return nil
	}
	pid, err := strconv.Atoi(string(pidBytes))
	if err != nil {
		// same as previous comment
		return nil
	}

	// os.FindProcess(pid) is a noop on linux...
	// it gives a wrapper for the PID, but does not actually try to find the process
	process, _ := os.FindProcess(pid)

	// $ man 2 kill
	// If sig is 0, then no signal is sent, but error checking is still performed;
	// this can be used to check for the existence of a process ID or process
	// group ID.
	err = process.Signal(syscall.Signal(0))
	if err != nil {
		return nil
	}
	return process
}
