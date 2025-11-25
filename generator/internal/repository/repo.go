package repository

import "github.com/Gerkkk/MetroPulse/generator/internal/models"

type PaymentRepo interface {
	AddPayment(payment models.Payment) error
}
type UserRepo interface {
	AddUser(user models.User) error
	AddRide(ride models.Ride) error
}
type VehicleRepo interface {
	AddVehicle(vehicle models.Vehicle) error
	AddRoute(route models.Route) error
}

type Repository struct {
	Payment PaymentRepo
	User    UserRepo
	Vehicle VehicleRepo
}
