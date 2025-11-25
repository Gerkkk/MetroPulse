package main

import (
	"github.com/Gerkkk/MetroPulse/generator/internal/clients"
)

type ClientConfig struct {
	PosBrockerAddr string `json:"pos_addr"`
	PosTopic       string `json:"pos_topic"`
}

func SetupClients(cfg ClientConfig) *clients.KafkaClient {
	client := clients.NewKafkaClient(cfg.PosBrockerAddr, cfg.PosTopic)
	return client
}
