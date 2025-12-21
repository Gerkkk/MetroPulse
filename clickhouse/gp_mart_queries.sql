create schema if not exists mart;

drop table if exists mart.mart_route_hourly;

create table mart.mart_route_hourly as
with
l_ride_route as (
  select id_ride, id_route
  from (
    select *, row_number() over (partition by id order by load_date desc) rn
    from "L_RIDE_ROUTE"
  ) t
  where rn = 1
),
l_ride_user as (
  select id_ride, id_user
  from (
    select *, row_number() over (partition by id order by load_date desc) rn
    from "L_RIDE_USER"
  ) t
  where rn = 1
),
l_ride_payment as (
  select id_ride, id_payment
  from (
    select *, row_number() over (partition by id order by load_date desc) rn
    from "L_RIDE_PAYMENT"
  ) t
  where rn = 1
),
h_routes as (
  select id, route_id
  from (
    select *, row_number() over (partition by id order by load_date desc) rn
    from "H_ROUTES"
  ) t
  where rn = 1
),
s_routes as (
  select * from "S_ROUTES"
),
s_rides as (
  select * from "S_RIDES"
),
s_payments as (
  select * from "S_PAYMENTS"
),
base as (
  select
    date_trunc('hour', sr.start_time)                         as hour_ts,
    rr.id_route                                               as id_route,
    rr.id_ride                                                as id_ride,
    ru.id_user                                                as id_user,
    rp.id_payment                                             as id_payment,
    extract(epoch from (sr.end_time - sr.start_time))::float8  as ride_duration_sec,
    sr.fare_amount::numeric                                   as fare_amount,
    sp.amount::numeric                                        as payment_amount,
    sp.status::varchar                                        as payment_status
  from l_ride_route rr
  join s_rides sr
    on sr.id = rr.id_ride
   and sr.is_current = true
  left join l_ride_user ru
    on ru.id_ride = rr.id_ride
  left join l_ride_payment rp
    on rp.id_ride = rr.id_ride
  left join s_payments sp
    on sp.id = rp.id_payment
   and sp.is_current = true
)
select
  b.hour_ts,
  hr.route_id,

  r.route_number,
  r.vehicle_type,
  r.base_fare,

  count(distinct b.id_ride) as rides_cnt,
  count(distinct b.id_user) as uniq_users_cnt,

  sum(case when b.id_payment is not null then 1 else 0 end) as payments_cnt,
  sum(case when b.payment_status = 'success' then 1 else 0 end) as success_payments_cnt,
  sum(case when b.id_payment is not null and b.payment_status <> 'success' then 1 else 0 end) as failed_payments_cnt,

  sum(case when b.payment_status = 'success' then b.payment_amount else 0 end) as revenue_sum,
  avg(b.fare_amount) as avg_fare,
  avg(b.ride_duration_sec) as avg_ride_duration_sec
from base b
join h_routes hr
  on hr.id = b.id_route
left join s_routes r
  on r.id = b.id_route
 and b.hour_ts >= r.valid_from
 and (r.valid_to is null or b.hour_ts < r.valid_to)
group by
  b.hour_ts, hr.route_id, r.route_number, r.vehicle_type, r.base_fare
;



drop table if exists mart.mart_route_speed_hourly;

create table mart.mart_route_speed_hourly as
with
l_position_vehicle as (
  select id_position, id_vehicle
  from (
    select *, row_number() over (partition by id order by load_date desc) rn
    from "L_POSITION_VEHICLE"
  ) t
  where rn = 1
),
l_route_vehicle as (
  select id_route, id_vehicle
  from (
    select *, row_number() over (partition by id order by load_date desc) rn
    from "L_ROUTE_VEHICLE"
  ) t
  where rn = 1
),
h_routes as (
  select id, route_id
  from (
    select *, row_number() over (partition by id order by load_date desc) rn
    from "H_ROUTES"
  ) t
  where rn = 1
),
s_routes as (
  select * from "S_ROUTES"
),
s_positions as (
  select * from "S_POSITIONS"
),
base as (
  select
    date_trunc('hour', sp.created_at) as hour_ts,
    lrv.id_route                      as id_route,
    lpv.id_vehicle                    as id_vehicle,
    sp.speed::numeric                 as speed,
    sp.passengers_estimated::int      as passengers_estimated
  from l_position_vehicle lpv
  join s_positions sp
    on sp.id = lpv.id_position
   and sp.is_current = true
  join l_route_vehicle lrv
    on lrv.id_vehicle = lpv.id_vehicle
)
select
  b.hour_ts,
  hr.route_id,

  r.route_number,
  r.vehicle_type,

  count(*) as events_cnt,
  count(distinct b.id_vehicle) as active_vehicles_cnt,

  avg(b.speed) as avg_speed,
  percentile_cont(0.50) within group (order by b.speed) as p50_speed,
  percentile_cont(0.95) within group (order by b.speed) as p95_speed,

  avg(b.passengers_estimated) as avg_passengers_estimated
from base b
join h_routes hr
  on hr.id = b.id_route
left join s_routes r
  on r.id = b.id_route
 and b.hour_ts >= r.valid_from
 and (r.valid_to is null or b.hour_ts < r.valid_to)
group by
  b.hour_ts, hr.route_id, r.route_number, r.vehicle_type
;


drop table if exists mart.mart_city_kpi_hourly;

create table mart.mart_city_kpi_hourly as
with
l_ride_route as (
  select id_ride, id_route
  from (
    select *, row_number() over (partition by id order by load_date desc) rn
    from "L_RIDE_ROUTE"
  ) t
  where rn = 1
),
l_ride_user as (
  select id_ride, id_user
  from (
    select *, row_number() over (partition by id order by load_date desc) rn
    from "L_RIDE_USER"
  ) t
  where rn = 1
),
l_ride_vehicle as (
  select id_ride, id_vehicle
  from (
    select *, row_number() over (partition by id order by load_date desc) rn
    from "L_RIDE_VEHICLE"
  ) t
  where rn = 1
),
l_ride_payment as (
  select id_ride, id_payment
  from (
    select *, row_number() over (partition by id order by load_date desc) rn
    from "L_RIDE_PAYMENT"
  ) t
  where rn = 1
),
s_rides as (select * from "S_RIDES"),
s_users as (select * from "S_USERS"),
s_routes as (select * from "S_ROUTES"),
s_payments as (select * from "S_PAYMENTS"),
base as (
  select
    date_trunc('hour', sr.start_time) as hour_ts,
    rr.id_route                       as id_route,
    ru.id_user                        as id_user,
    rv.id_vehicle                     as id_vehicle,
    rp.id_payment                     as id_payment,
    sr.start_time                     as ride_ts,
    sp.amount::numeric                as payment_amount,
    sp.status::varchar                as payment_status
  from l_ride_route rr
  join s_rides sr
    on sr.id = rr.id_ride
   and sr.is_current = true
  left join l_ride_user ru
    on ru.id_ride = rr.id_ride
  left join l_ride_vehicle rv
    on rv.id_ride = rr.id_ride
  left join l_ride_payment rp
    on rp.id_ride = rr.id_ride
  left join s_payments sp
    on sp.id = rp.id_payment
   and sp.is_current = true
)
select
  b.hour_ts,
  u.city,
  r.vehicle_type,

  count(*) as rides_cnt,
  count(distinct b.id_user) as uniq_users_cnt,
  count(distinct b.id_vehicle) as active_vehicles_cnt_from_rides,
  sum(case when b.payment_status = 'success' then b.payment_amount else 0 end) as revenue_sum
from base b
left join s_users u
  on u.id = b.id_user
 and b.ride_ts >= u.valid_from
 and (u.valid_to is null or b.ride_ts < u.valid_to)
left join s_routes r
  on r.id = b.id_route
 and b.hour_ts >= r.valid_from
 and (r.valid_to is null or b.hour_ts < r.valid_to)
group by
  b.hour_ts, u.city, r.vehicle_type
;
