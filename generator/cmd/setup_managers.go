package main

import (
	"encoding/json"
	"github.com/Gerkkk/MetroPulse/generator/internal/clients"
	"github.com/Gerkkk/MetroPulse/generator/internal/managers"
	repo "github.com/Gerkkk/MetroPulse/generator/internal/repository"
	"os"
)

type ManagerConfig struct {
	DataPath string `json:"dataPath"`
}

func SetupManagers(cfg ManagerConfig, r *repo.Repository, c *clients.KafkaClient) (*managers.Generator, error) {
	buf, err := os.ReadFile(cfg.DataPath)

	if err != nil {
		return nil, err
	}

	var rd managers.RawData

	err = json.Unmarshal(buf, &rd)

	if err != nil {
		return nil, err
	}

	return managers.NewGenerator(rd, r, c), nil
}
