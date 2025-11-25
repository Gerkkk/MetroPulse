package main

import (
	"context"
	"encoding/json"
	_ "github.com/lib/pq"
	"log"
	"os"
	"os/signal"
	"syscall"
	"time"
)

type Config struct {
	ClientConfig  *ClientConfig  `json:"client_config"`
	ManagerConfig *ManagerConfig `json:"manager_config"`
	DBConfig      *DBConfig      `json:"db_config"`
}

func main() {
	buf, err := os.ReadFile("configs/generator_configs.json")
	if err != nil {
		panic(err)
	}

	var cfg Config

	err = json.Unmarshal(buf, &cfg)

	if err != nil {
		panic(err)
	}

	repo, err := SetupRepositories(*cfg.DBConfig)

	if err != nil {
		panic(err)
	}

	client := SetupClients(*cfg.ClientConfig)

	managers, err := SetupManagers(*cfg.ManagerConfig, repo, client)

	if err != nil {
		panic(err)
	}

	ctx := context.Background()
	cancelCtx, cancel := context.WithCancel(ctx)

	serviceErr := make(chan error, 1)
	go func() {
		err := managers.Serve(cancelCtx)
		if err != nil {
			serviceErr <- err
		}
	}()

	defer cancel()

	sigChan := make(chan os.Signal, 1)
	signal.Notify(sigChan, syscall.SIGINT, syscall.SIGTERM)

	select {
	case err := <-serviceErr:
		log.Printf("Service stopped with error: %v", err)
	case sig := <-sigChan:
		log.Printf("Received signal: %v", sig)
		cancel()
		time.Sleep(2 * time.Second)
		log.Println("Service stopped gracefully")
	}
}
