CREATE TABLE RAW_USERS (
    user_id INTEGER,
    user_name VARCHAR,
    email VARCHAR,
    city VARCHAR,
    created_at TIMESTAMP,
    upload_timestamp TIMESTAMP,
    load_sorce VARCHAR
);

CREATE TABLE RAW_ROUTES (
    route_id INTEGER,
    route_number VARCHAR,
    vehicle_type VARCHAR,
    base_fare DECIMAL(10, 2),
    upload_timestamp TIMESTAMP,
    load_sorce VARCHAR
);

CREATE TABLE RAW_VEHICLES (
    vehicle_id INTEGER,
    route_id INTEGER,
    licence_plate VARCHAR,
    capacity INTEGER,
    upload_timestamp TIMESTAMP,
    load_sorce VARCHAR
);

CREATE TABLE RAW_RIDES (
    ride_id VARCHAR,
    user_id INTEGER,
    route_id INTEGER,
    vehicle_id INTEGER,
    start_time TIMESTAMP,
    end_time TIMESTAMP,
    fare_amount DECIMAL(10, 2),
    upload_timestamp TIMESTAMP,
    load_sorce VARCHAR
);

CREATE TABLE RAW_PAYMENTS (
    payment_id VARCHAR,
    ride_id VARCHAR,
    user_id INTEGER,
    amount DECIMAL(10, 2),
    payment_method VARCHAR,
    payment_status VARCHAR,
    upload_timestamp TIMESTAMP,
    load_sorce VARCHAR,
    created_at TIMESTAMP
);

CREATE TABLE RAW_POSITIONS (
    event_id VARCHAR,
    vehicle_id INTEGER,
    route_number VARCHAR,
    latitude DECIMAL(20, 10),
    longitude DECIMAL(20, 10),
    speed DECIMAL(10, 2),
    passengers_estimated INTEGER,
    event_time TIMESTAMP,
    upload_timestamp TIMESTAMP,
    load_sorce VARCHAR
);