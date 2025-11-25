CREATE TABLE USERS (
    user_id INTEGER PRIMARY KEY,
    name VARCHAR,
    email VARCHAR UNIQUE,
    created_at TIMESTAMP,
    city VARCHAR
);

CREATE TABLE ROUTES (
    route_id INTEGER PRIMARY KEY,
    route_number VARCHAR,
    vehicle_type VARCHAR,
    base_fare DECIMAL(10, 2)
);

CREATE TABLE VEHICLES (
    vehicle_id INTEGER PRIMARY KEY,
    route_id INTEGER,
    licence_plate VARCHAR,
    capacity INTEGER
);

CREATE TABLE RIDES (
    ride_id UUID PRIMARY KEY,
    user_id INTEGER,
    route_id INTEGER,
    vehicle_id INTEGER,
    start_time TIMESTAMP,
    end_time TIMESTAMP,
    fare_amount DECIMAL(10, 2)
);

CREATE TABLE PAYMENTS (
    payment_id UUID PRIMARY KEY,
    ride_id UUID,
    user_id INTEGER,
    amount DECIMAL(10, 2),
    payment_method VARCHAR,
    status VARCHAR,
    created_at TIMESTAMP
);
