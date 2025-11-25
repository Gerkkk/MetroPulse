package clients

import (
	"context"
	kafka "github.com/segmentio/kafka-go"
)

func NewKafkaClient(addr, topic string) *KafkaClient {
	kafkaWriter := kafka.NewWriter(kafka.WriterConfig{
		Brokers:  []string{addr},
		Topic:    topic,
		Balancer: &kafka.Hash{},
	})

	return &KafkaClient{writer: kafkaWriter}
}

type KafkaClient struct {
	writer *kafka.Writer
}

func (kc *KafkaClient) WriteMessages(msgs [][]byte) error {
	kafkaMessages := make([]kafka.Message, len(msgs))
	for i, msg := range msgs {
		kafkaMessages[i] = kafka.Message{Value: msg}
	}

	err := kc.writer.WriteMessages(context.Background(), kafkaMessages...)

	if err != nil {
		return err
	}

	return nil
}
