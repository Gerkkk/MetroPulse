from pyspark.sql import SparkSession
from pyspark.sql.functions import *
from raw_loader import get_and_write_raw_tables
from utils import DWHWorker, get_distinct_col_as_list, get_sat_core_table, get_unique_col_by_table, set_invalid, add_cur_valid
from core_loader import *

spark = SparkSession.builder.getOrCreate()

jdbc_driver = spark.conf.get("spark.jdbc.driver")
jdbc_url = spark.conf.get("spark.jdbc.url")
jdbc_user = spark.conf.get("spark.jdbc.user")
jdbc_password = spark.conf.get("spark.jdbc.password")
jdbc_jar = spark.conf.get("spark.jdbc.jar")

jdbc_connection_properties = {
    "user": jdbc_user,
    "password": jdbc_password,
    "driver": jdbc_driver
}

dwh = DWHWorker(spark, jdbc_connection_properties, jdbc_url, jdbc_jar)
raw_table_names = ['users', 'routes', 'vehicles', 'rides', 'payments', POSITIONS_TABLE]
users, routes, vehicles, rides, payments, positions = get_and_write_raw_tables(spark, raw_table_names, jdbc_connection_properties, jdbc_url)

store_positions(dwh, positions)