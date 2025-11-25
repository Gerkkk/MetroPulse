package models

import (
	"github.com/google/uuid"
	"time"
)

type User struct {
	UserId    int32     `db:"user_id"`
	Name      string    `db:"name"`
	Email     string    `db:"email"`
	CreatedAt time.Time `db:"created_at"`
	City      string    `db:"city"`
}

type Ride struct {
	RideId     uuid.UUID `db:"ride_id"`
	UserId     int32     `db:"user_id"`
	RouteId    int32     `db:"route_id"`
	VehicleId  int32     `db:"vehicle_id"`
	StartTime  time.Time `db:"start_time"`
	EndTime    time.Time `db:"end_time"`
	FareAmount int32     `db:"fare_amount"`
}
