package models

type Vehicle struct {
	VehicleId    int32  `db:"vehicle_id"`
	RouteId      int32  `db:"route_id"`
	LicencePlate string `db:"licence_plate"`
	Capacity     int32  `db:"capacity"`
}

type Route struct {
	RouteId     int32  `db:"route_id"`
	RouteNumber string `db:"route_number"`
	VehicleType string `db:"vehicle_type"`
	BaseFare    int32  `db:"base_fare"`
}
