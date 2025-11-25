package payment

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

func (r *Repo) AddPayment(payment models.Payment) error {
	_, err := r.db.NamedExec(`
	INSERT INTO payments (payment_id, ride_id, user_id, amount, payment_method, status, created_at)
	VALUES (:payment_id, :ride_id, :user_id, :amount, :payment_method, :status, :created_at)`,
		map[string]interface{}{
			"payment_id":     payment.PaymentId,
			"ride_id":        payment.RideId,
			"user_id":        payment.UserId,
			"amount":         payment.Amount,
			"payment_method": payment.PaymentMethod,
			"status":         payment.Status,
			"created_at":     payment.CreatedAt,
		})
	if err != nil {
		return err
	}

	return nil
}
