package main

import (
	"fmt"
	repo "github.com/Gerkkk/MetroPulse/generator/internal/repository"
	payment "github.com/Gerkkk/MetroPulse/generator/internal/repository/payment"
	user "github.com/Gerkkk/MetroPulse/generator/internal/repository/user"
	vehicle "github.com/Gerkkk/MetroPulse/generator/internal/repository/vehicle"
	"github.com/jmoiron/sqlx"
)

type DBConfig struct {
	Host     string `json: "host"`
	Port     string `json: "port"`
	Username string `json: "username"`
	Password string `json: "password"`
	DBName   string `json: "dbname"`
	SSLMode  string `json: "sslmode"`
}

func SetupRepositories(cfg DBConfig) (*repo.Repository, error) {
	db, err := sqlx.Open("postgres", fmt.Sprintf("host=%s port=%s user=%s password=%s dbname=%s sslmode=%s",
		cfg.Host, cfg.Port, cfg.Username, cfg.Password, cfg.DBName, cfg.SSLMode))

	if err != nil {
		return nil, err
	}

	err = db.Ping()
	if err != nil {
		return nil, err
	}

	paymentRepo := payment.New(db)
	userRepo := user.New(db)
	vehicleRepo := vehicle.New(db)

	return &repo.Repository{paymentRepo, userRepo, vehicleRepo}, nil
}
