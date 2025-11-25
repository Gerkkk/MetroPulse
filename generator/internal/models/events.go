package models

import "time"

type Coordinates struct {
	Latitude  float64 `json:"latitude"`
	Longitude float64 `json:"longitude"`
}
type VehiclePositionEvent struct {
	EventId             string      `json:"event_id"`
	VehicleId           int32       `json:"vehicle_id"`
	RouteNumber         string      `json:"route_number"`
	EventTime           time.Time   `json:"event_type"`
	Coordinates         Coordinates `json:"coordinates"`
	SpeedKMH            float32     `json:"speed_kmh"`
	PassengersEstimated int32       `json:"passengers_estimated"`
}
