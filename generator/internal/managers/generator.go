package managers

import (
	"context"
	"encoding/json"
	"fmt"
	"github.com/Gerkkk/MetroPulse/generator/internal/clients"
	"github.com/Gerkkk/MetroPulse/generator/internal/models"
	repo "github.com/Gerkkk/MetroPulse/generator/internal/repository"
	"github.com/google/uuid"
	"math/rand"
	"strconv"
	"time"
)

const (
	tickTime               time.Duration = time.Second * 1
	routeGenPeriod         int           = 60
	transportGenPeriod     int           = 20
	userGenPeriod          int           = 10
	ridesPaymentsGenPeriod int           = 3
	vehiclePosGenPeriod    int           = 5
	newRouteProba          float32       = 0.1
)

type RawData struct {
	RoutePrefixes     []string `json:"route_prefix"`
	VehicleTypes      []string `json:"vehicle_type"`
	VehicleCosts      []int32  `json:"vehicle_cost"`
	PeopleNames       []string `json:"first_name"`
	PeopleSecondNames []string `json:"second_name"`
	PeopleEmails      []string `json:"email"`
	Cities            []string `json:"city"`
	PaymentMethods    []string `json:"payment_method"`
	PaymentStatus     []string `json:"payment_status"`
}

func NewGenerator(rd RawData, r *repo.Repository, c *clients.KafkaClient) *Generator {
	return &Generator{rawData: rd, repo: r, client: c, rand: rand.New(rand.NewSource(66))}
}

type Generator struct {
	rawData      RawData
	repo         *repo.Repository
	client       *clients.KafkaClient
	users        []models.User
	vehicles     []models.Vehicle
	vehiclePoses []models.VehiclePositionEvent
	routes       []models.Route
	rand         *rand.Rand
}

func (g *Generator) Serve(ctx context.Context) error {
	i := 0

	for {
		select {
		case <-ctx.Done():
			return ctx.Err()
		case <-time.After(tickTime):
			fmt.Println("Tick")
			if i%userGenPeriod == 0 {
				_ = g.generateUsers(ctx)
			}

			if i%transportGenPeriod == 0 {
				_ = g.generateTransport(ctx)
			}

			if i%ridesPaymentsGenPeriod == 0 {
				_ = g.generateRidesPayments(ctx)
			}

			if i%vehiclePosGenPeriod == 0 {
				_ = g.generateVehiclePoses(ctx)
			}

			i++
		}
	}
}

func (g *Generator) generateUsers(ctx context.Context) error {
	for i := 0; i < 5; i++ {
		user := g.RandomUser(int32(len(g.users) + i))
		g.users = append(g.users, *user)

		_ = g.repo.User.AddUser(*user)
		fmt.Printf("User added: %v\n", user)
	}

	return nil
}

func (g *Generator) generateTransport(ctx context.Context) error {
	needGen := rand.Float32() <= newRouteProba

	var route *models.Route
	if needGen || len(g.routes) == 0 {
		route = g.RandomRoute(int32(len(g.routes)))
		g.routes = append(g.routes, *route)
		_ = g.repo.Vehicle.AddRoute(*route)
	} else {
		route = &g.routes[rand.Intn(len(g.routes))]
	}

	for i := 0; i < 5; i++ {
		veh := g.RandomVehicle(int32(len(g.vehicles)), route.RouteId)
		g.vehicles = append(g.vehicles, *veh)

		vehPos := g.RandomVehiclePos(veh.VehicleId, route.RouteId)
		g.vehiclePoses = append(g.vehiclePoses, *vehPos)

		_ = g.repo.Vehicle.AddVehicle(*veh)
	}

	return nil
}

func (g *Generator) generateRidesPayments(ctx context.Context) error {
	for i := 0; i < 5; i++ {
		ride, payment := g.RandomRidePayment()

		_ = g.repo.Payment.AddPayment(*payment)
		_ = g.repo.User.AddRide(*ride)
	}

	return nil
}

func (g *Generator) generateVehiclePoses(ctx context.Context) error {
	messages := make([][]byte, 0)
	for _, pos := range g.vehiclePoses {
		msgEncoded, err := json.Marshal(pos)
		if err != nil {
			return err
		}
		messages = append(messages, msgEncoded)
	}

	err := g.client.WriteMessages(messages)

	fmt.Printf("error sending vehicle poses: %v\n", err)

	if err != nil {
		return err
	}
	fmt.Printf("sent vehicle poses: %v\n", g.vehiclePoses)
	return nil
}

func (g *Generator) RandomUser(userId int32) *models.User {
	return &models.User{
		UserId:    userId,
		Name:      g.rawData.PeopleNames[rand.Intn(len(g.rawData.PeopleNames))] + " " + g.rawData.PeopleSecondNames[rand.Intn(len(g.rawData.PeopleSecondNames))],
		Email:     g.rawData.PeopleEmails[rand.Intn(len(g.rawData.PeopleEmails))] + strconv.Itoa(rand.Intn(999)) + "@gmail.com",
		CreatedAt: time.Now(),
		City:      g.rawData.Cities[rand.Intn(len(g.rawData.Cities))],
	}
}

func (g *Generator) RandomVehicle(vehId int32, routeId int32) *models.Vehicle {
	return &models.Vehicle{
		VehicleId:    vehId,
		RouteId:      routeId,
		LicencePlate: strconv.Itoa(int(rand.Int31())),
		Capacity:     int32(rand.Intn(50) + 50),
	}
}

func (g *Generator) RandomVehiclePos(vehId int32, routeId int32) *models.VehiclePositionEvent {
	var signLong, signLat float64

	if rand.Float64() < 0.5 {
		signLong = -1.0
	} else {
		signLong = 1.0
	}

	if rand.Float64() < 0.5 {
		signLat = -1.0
	} else {
		signLat = 1.0
	}

	return &models.VehiclePositionEvent{
		EventId:     uuid.Must(uuid.NewRandom()).String(),
		VehicleId:   vehId,
		EventTime:   time.Now(),
		RouteNumber: g.routes[routeId].RouteNumber,
		Coordinates: models.Coordinates{
			Latitude:  signLat * rand.Float64() * float64(90),
			Longitude: signLong * rand.Float64() * float64(90),
		},
		SpeedKMH:            rand.Float32() * float32(60),
		PassengersEstimated: int32(rand.Intn(100)),
	}
}

func (g *Generator) RandomRoute(routeId int32) *models.Route {
	vehTInd := rand.Intn(len(g.rawData.VehicleTypes))
	return &models.Route{
		RouteId:     routeId,
		RouteNumber: g.rawData.RoutePrefixes[rand.Intn(len(g.rawData.RoutePrefixes))] + "-" + strconv.Itoa(int(rand.Intn(1000))),
		VehicleType: g.rawData.VehicleTypes[vehTInd],
		BaseFare:    g.rawData.VehicleCosts[vehTInd],
	}
}

func (g *Generator) RandomRidePayment() (*models.Ride, *models.Payment) {
	rideId := uuid.Must(uuid.NewRandom())
	userId := rand.Intn(len(g.users))
	vehicleId := rand.Intn(len(g.vehicles))
	routeId := g.vehicles[vehicleId].RouteId
	startTime := time.Now()
	endTime := time.Now().Add(time.Duration(rand.Intn(60)) * time.Minute)
	fareAmount := g.routes[routeId].BaseFare

	retRide := &models.Ride{
		RideId:     rideId,
		RouteId:    routeId,
		UserId:     int32(userId),
		VehicleId:  int32(vehicleId),
		StartTime:  startTime,
		EndTime:    endTime,
		FareAmount: int32(fareAmount),
	}

	payment := &models.Payment{
		RideId:        rideId,
		PaymentId:     uuid.Must(uuid.NewRandom()),
		UserId:        int32(userId),
		Amount:        int32(fareAmount),
		PaymentMethod: g.rawData.PaymentMethods[rand.Intn(len(g.rawData.PaymentMethods))],
		Status:        g.rawData.PaymentStatus[rand.Intn(len(g.rawData.PaymentStatus))],
		CreatedAt:     time.Now(),
	}

	return retRide, payment
}
