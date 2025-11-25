#!/bin/bash
echo "Waiting for Kafka to be ready..."

until kafka-topics --bootstrap-server localhost:9092 --list; do
  echo "Waiting for Kafka..."
  sleep 5
done

echo "Kafka is ready. Creating topic vehicle_positions"
kafka-topics --bootstrap-server localhost:9092 --create \
  --topic vehicle_positions \
  --partitions 1 \
  --replication-factor 1

echo "Topic vehicle_positions created successfully"