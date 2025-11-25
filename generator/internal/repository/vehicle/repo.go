package vehicle

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

func (r *Repo) AddVehicle(vehicle models.Vehicle) error {
	_, err := r.db.NamedExec(`
	INSERT INTO vehicles (vehicle_id, route_id, licence_plate, capacity)
	VALUES (:vehicle_id, :route_id, :licence_plate, :capacity)`,
		map[string]interface{}{
			"vehicle_id":    vehicle.VehicleId,
			"route_id":      vehicle.RouteId,
			"licence_plate": vehicle.LicencePlate,
			"capacity":      vehicle.Capacity,
		})
	if err != nil {
		return err
	}

	return nil
}

func (r *Repo) AddRoute(route models.Route) error {
	_, err := r.db.NamedExec(`
	INSERT INTO routes (route_id, route_number, vehicle_type, base_fare)
	VALUES (:route_id, :route_number, :vehicle_type, :base_fare)`,
		map[string]interface{}{
			"route_id":     route.RouteId,
			"route_number": route.RouteNumber,
			"vehicle_type": route.VehicleType,
			"base_fare":    route.BaseFare,
		})
	if err != nil {
		return err
	}

	return nil
}
