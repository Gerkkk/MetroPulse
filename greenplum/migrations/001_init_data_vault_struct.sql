CREATE TABLE H_USERS (
  id varchar,
  user_id integer,
  load_date timestamp,
  load_sorce varchar
)
WITH (appendonly=true, orientation=column, compresstype=ZSTD)
DISTRIBUTED BY (id)
PARTITION BY RANGE (load_date)
(START (date '2000-01-01') INCLUSIVE
 END (date '2030-01-01') EXCLUSIVE
 EVERY (INTERVAL '12 month'));

CREATE UNIQUE INDEX h_users_id_load_date_unique ON H_USERS (id, load_date);

CREATE TABLE H_POSITIONS (
  id varchar,
  postition_event_id integer,
  load_date timestamp,
  load_sorce varchar
)
WITH (appendonly=true, orientation=column, compresstype=ZSTD)
DISTRIBUTED BY (id)
PARTITION BY RANGE (load_date)
(START (date '2000-01-01') INCLUSIVE
 END (date '2030-01-01') EXCLUSIVE
 EVERY (INTERVAL '12 month'));

CREATE UNIQUE INDEX h_positions_id_load_date_unique ON H_POSITIONS (id, load_date);

CREATE TABLE H_ROUTES (
  id varchar,
  route_id integer,
  load_date timestamp,
  load_sorce varchar
)
WITH (appendonly=true, orientation=column, compresstype=ZSTD)
DISTRIBUTED BY (id)
PARTITION BY RANGE (load_date)
(START (date '2000-01-01') INCLUSIVE
 END (date '2030-01-01') EXCLUSIVE
 EVERY (INTERVAL '12 month'));

CREATE UNIQUE INDEX h_routes_id_load_date_unique ON H_ROUTES (id, load_date);

CREATE TABLE H_VEHICLES (
  id varchar,
  vehicle_id integer,
  load_date timestamp,
  load_sorce varchar
)
WITH (appendonly=true, orientation=column, compresstype=ZSTD)
DISTRIBUTED BY (id)
PARTITION BY RANGE (load_date)
(START (date '2000-01-01') INCLUSIVE
 END (date '2030-01-01') EXCLUSIVE
 EVERY (INTERVAL '12 month'));

CREATE UNIQUE INDEX h_vehicles_id_load_date_unique ON H_VEHICLES (id, load_date);

CREATE TABLE H_RIDES (
  id varchar,
  ride_id varchar,
  load_date timestamp,
  load_sorce varchar
)
WITH (appendonly=true, orientation=column, compresstype=ZSTD)
DISTRIBUTED BY (id)
PARTITION BY RANGE (load_date)
(START (date '2000-01-01') INCLUSIVE
 END (date '2030-01-01') EXCLUSIVE
 EVERY (INTERVAL '12 month'));

CREATE UNIQUE INDEX h_rides_id_load_date_unique ON H_RIDES (id, load_date);

CREATE TABLE H_PAYMENTS (
  id varchar,
  payment_id varchar,
  load_date timestamp,
  load_sorce varchar
)
WITH (appendonly=true, orientation=column, compresstype=ZSTD)
DISTRIBUTED BY (id)
PARTITION BY RANGE (load_date)
(START (date '2000-01-01') INCLUSIVE
 END (date '2030-01-01') EXCLUSIVE
 EVERY (INTERVAL '12 month'));

CREATE UNIQUE INDEX h_payments_id_load_date_unique ON H_PAYMENTS (id, load_date);

CREATE TABLE L_ROUTE_VEHICLE (
  id varchar,
  id_route varchar,
  id_vehicle varchar,
  load_date timestamp,
  load_sorce varchar
)
WITH (appendonly=true, orientation=column, compresstype=ZSTD)
DISTRIBUTED BY (id)
PARTITION BY RANGE (load_date)
(START (date '2000-01-01') INCLUSIVE
 END (date '2030-01-01') EXCLUSIVE
 EVERY (INTERVAL '12 month'));

CREATE UNIQUE INDEX l_route_vehicles_id_load_date_unique ON L_ROUTE_VEHICLE (id, load_date);

CREATE TABLE L_USER_PAYMENT (
  id varchar,
  id_user varchar,
  id_payment varchar,
  load_date timestamp,
  load_sorce varchar
)
WITH (appendonly=true, orientation=column, compresstype=ZSTD)
DISTRIBUTED BY (id)
PARTITION BY RANGE (load_date)
(START (date '2000-01-01') INCLUSIVE
 END (date '2030-01-01') EXCLUSIVE
 EVERY (INTERVAL '12 month'));

CREATE UNIQUE INDEX l_user_payment_id_load_date_unique ON L_USER_PAYMENT (id, load_date);

CREATE TABLE L_RIDE_ROUTE (
  id varchar,
  id_ride varchar,
  id_route varchar,
  load_date timestamp,
  load_sorce varchar
)
WITH (appendonly=true, orientation=column, compresstype=ZSTD)
DISTRIBUTED BY (id)
PARTITION BY RANGE (load_date)
(START (date '2000-01-01') INCLUSIVE
 END (date '2030-01-01') EXCLUSIVE
 EVERY (INTERVAL '12 month'));

CREATE UNIQUE INDEX l_ride_route_id_load_date_unique ON L_RIDE_ROUTE (id, load_date);

CREATE TABLE L_RIDE_PAYMENT (
  id varchar,
  id_ride varchar,
  id_payment varchar,
  load_date timestamp,
  load_sorce varchar
)
WITH (appendonly=true, orientation=column, compresstype=ZSTD)
DISTRIBUTED BY (id)
PARTITION BY RANGE (load_date)
(START (date '2000-01-01') INCLUSIVE
 END (date '2030-01-01') EXCLUSIVE
 EVERY (INTERVAL '12 month'));

CREATE UNIQUE INDEX l_ride_payment_id_load_date_unique ON L_RIDE_PAYMENT (id, load_date);

CREATE TABLE L_RIDE_VEHICLE (
  id varchar,
  id_ride varchar,
  id_vehicle varchar,
  load_date timestamp,
  load_sorce varchar
)
WITH (appendonly=true, orientation=column, compresstype=ZSTD)
DISTRIBUTED BY (id)
PARTITION BY RANGE (load_date)
(START (date '2000-01-01') INCLUSIVE
 END (date '2030-01-01') EXCLUSIVE
 EVERY (INTERVAL '12 month'));

CREATE UNIQUE INDEX l_ride_vehicle_id_load_date_unique ON L_RIDE_VEHICLE (id, load_date);

CREATE TABLE L_RIDE_USER (
  id varchar,
  id_ride varchar,
  id_user varchar,
  load_date timestamp,
  load_sorce varchar
)
WITH (appendonly=true, orientation=column, compresstype=ZSTD)
DISTRIBUTED BY (id)
PARTITION BY RANGE (load_date)
(START (date '2000-01-01') INCLUSIVE
 END (date '2030-01-01') EXCLUSIVE
 EVERY (INTERVAL '12 month'));

CREATE UNIQUE INDEX l_ride_user_id_load_date_unique ON L_RIDE_USER (id, load_date);

CREATE TABLE L_POSITION_VEHICLE (
  id varchar,
  id_position varchar,
  id_vehicle varchar,
  load_date timestamp,
  load_sorce varchar
)
WITH (appendonly=true, orientation=column, compresstype=ZSTD)
DISTRIBUTED BY (id)
PARTITION BY RANGE (load_date)
(START (date '2000-01-01') INCLUSIVE
 END (date '2030-01-01') EXCLUSIVE
 EVERY (INTERVAL '12 month'));

CREATE UNIQUE INDEX l_position_vehicle_id_load_date_unique ON L_POSITION_VEHICLE (id, load_date);

CREATE TABLE S_USERS (
  id varchar,
  name varchar,
  email varchar,
  created_at timestamp,
  city varchar,
  is_current bool,
  valid_from timestamp,
  valid_to timestamp,
  __ts_ms timestamp
)
WITH (appendonly=true, orientation=column, compresstype=ZSTD)
DISTRIBUTED BY (id)
PARTITION BY RANGE (created_at)
(START (date '2000-01-01') INCLUSIVE
 END (date '2030-01-01') EXCLUSIVE
 EVERY (INTERVAL '12 month'));

CREATE UNIQUE INDEX s_users_id_created_at_unique ON S_USERS (id, created_at);

CREATE TABLE S_ROUTES (
  id varchar,
  route_number varchar,
  vehicle_type varchar,
  base_fare DECIMAL(10,2),
  is_current bool,
  valid_from timestamp,
  valid_to timestamp,
  __ts_ms timestamp
)
WITH (appendonly=true, orientation=column, compresstype=ZSTD)
DISTRIBUTED BY (id)
PARTITION BY RANGE (valid_from)
(START (date '2000-01-01') INCLUSIVE
 END (date '2030-01-01') EXCLUSIVE
 EVERY (INTERVAL '12 month'));

CREATE UNIQUE INDEX s_routes_id_valid_from_unique ON S_ROUTES (id, valid_from);

CREATE TABLE S_VEHICLES (
  id varchar,
  license_plate varchar,
  capacity int,
  is_current bool,
  valid_from timestamp,
  valid_to timestamp,
  __ts_ms timestamp
)
WITH (appendonly=true, orientation=column, compresstype=ZSTD)
DISTRIBUTED BY (id)
PARTITION BY RANGE (valid_from)
(START (date '2000-01-01') INCLUSIVE
 END (date '2030-01-01') EXCLUSIVE
 EVERY (INTERVAL '12 month'));

CREATE UNIQUE INDEX s_vehicles_id_valid_from_unique ON S_VEHICLES (id, valid_from);

CREATE TABLE S_RIDES (
  id varchar,
  start_time timestamp,
  end_time timestamp,
  fare_amount DECIMAL(10,2),
  is_current bool,
  valid_from timestamp,
  valid_to timestamp,
  __ts_ms timestamp
)
WITH (appendonly=true, orientation=column, compresstype=ZSTD)
DISTRIBUTED BY (id)
PARTITION BY RANGE (start_time)
(START (date '2000-01-01') INCLUSIVE
 END (date '2030-01-01') EXCLUSIVE
 EVERY (INTERVAL '12 month'));

CREATE UNIQUE INDEX s_rides_id_start_time_unique ON S_RIDES (id, start_time);

CREATE TABLE S_PAYMENTS (
  id varchar,
  amount DECIMAL(10,2),
  payment_method varchar,
  status varchar,
  created_at timestamp,
  is_current bool,
  valid_from timestamp,
  valid_to timestamp
)
WITH (appendonly=true, orientation=column, compresstype=ZSTD)
DISTRIBUTED BY (id)
PARTITION BY RANGE (created_at)
(START (date '2000-01-01') INCLUSIVE
 END (date '2030-01-01') EXCLUSIVE
 EVERY (INTERVAL '12 month'));

CREATE UNIQUE INDEX s_payments_id_created_at_unique ON S_PAYMENTS (id, created_at);

CREATE TABLE S_POSITIONS (
  id varchar,
  latitude DECIMAL(20,10),
  longitude DECIMAL(20,10),
  speed DECIMAL(10,2),
  passengers_estimated integer,
  created_at timestamp,
  is_current bool,
  valid_from timestamp,
  valid_to timestamp
)
WITH (appendonly=true, orientation=column, compresstype=ZSTD)
DISTRIBUTED BY (id)
PARTITION BY RANGE (created_at)
(START (date '2000-01-01') INCLUSIVE
 END (date '2030-01-01') EXCLUSIVE
 EVERY (INTERVAL '12 month'));

CREATE UNIQUE INDEX s_positions_id_created_at_unique ON S_POSITIONS (id, created_at);