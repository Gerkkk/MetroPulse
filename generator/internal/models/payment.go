package models

import (
	"github.com/google/uuid"
	"time"
)

type Payment struct {
	PaymentId     uuid.UUID `db:"payment_id"`
	RideId        uuid.UUID `db:"ride_id"`
	UserId        int32     `db:"user_id"`
	Amount        int32     `db:"amount"`
	PaymentMethod string    `db:"payment_method"`
	Status        string    `db:"status"`
	CreatedAt     time.Time `db:"created_at"`
}
