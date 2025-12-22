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