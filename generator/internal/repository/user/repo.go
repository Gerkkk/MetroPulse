package user

import (
	"github.com/Gerkkk/MetroPulse/generator/internal/models"
	"github.com/jmoiron/sqlx"
)

func New(db *sqlx.DB) *Repo {
	return &Repo{db: db}
}

type Repo struct {
	db *sqlx.DB
}

func (r *Repo) AddUser(user models.User) error {
	_, err := r.db.NamedExec(`
	INSERT INTO users (user_id, name, email, created_at, city)
	VALUES (:user_id, :name, :email, :created_at, :city)`,
		map[string]interface{}{
			"user_id":    user.UserId,
			"name":       user.Name,
			"email":      user.Email,
			"created_at": user.CreatedAt,
			"city":       user.City,
		})
	if err != nil {
		return err
	}

	return nil
}

func (r *Repo) AddRide(ride models.Ride) error {
	_, err := r.db.NamedExec(`
	INSERT INTO rides (ride_id, user_id, route_id, vehicle_id, start_time, end_time, fare_amount)
	VALUES (:ride_id, :user_id, :route_id, :vehicle_id, :start_time, :end_time, :fare_amount)`,
		map[string]interface{}{
			"ride_id":     ride.RideId,
			"user_id":     ride.UserId,
			"route_id":    ride.RouteId,
			"vehicle_id":  ride.VehicleId,
			"start_time":  ride.StartTime,
			"end_time":    ride.EndTime,
			"fare_amount": ride.FareAmount,
		})
	if err != nil {
		return err
	}

	return nil
}
