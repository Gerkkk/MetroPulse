from pyspark.sql import SparkSession
from pyspark.sql.functions import *
from pyspark.sql import functions as F
from utils import *
import jaydebeapi
import uuid

POSITIONS_TABLE = "positions"
POSITIONS_INNER_ID_FIELD = "postition_event_id"

BASE_ID_FIELD = "id"
BASE_LOAD_DATE_FIELD = "load_date"
BASE_LOAD_SORCE_FIELD = "load_sorce"

def store_positions(dwh, positions):
    hub = get_hub_core_table(POSITIONS_TABLE)

    positions = positions.withColumnRenamed("event_time", "created_at") # Add renames to match core layer
    positions = positions.withColumnRenamed("event_id", POSITIONS_INNER_ID_FIELD)
    positions = set_or_create_ids(positions, dwh, hub, POSITIONS_INNER_ID_FIELD)

    position_ids = get_distinct_col_as_list(positions, get_unique_col_by_table(POSITIONS_TABLE))
    valid_tss_positions = dwh.get_cur_valid_tss_by_table(positions, get_sat_core_table(POSITIONS_TABLE), position_ids)

    positions = add_cur_valid(positions, POSITIONS_TABLE)
    positions = set_invalid(positions, dwh, POSITIONS_TABLE, valid_tss_positions)

    dwh.store(positions
              .drop("load_date")
              .drop("vehicle_id")
              .drop("load_sorce")
              .drop("upload_timestamp")
              .drop("route_number")
              .drop(POSITIONS_INNER_ID_FIELD),
              get_sat_core_table(POSITIONS_TABLE))
    
    positions.show()
    dwh.store(positions.select("id", POSITIONS_INNER_ID_FIELD, F.col("created_at").alias("load_date"), "load_sorce"),
              get_hub_core_table(POSITIONS_TABLE))
