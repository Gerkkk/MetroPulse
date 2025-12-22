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