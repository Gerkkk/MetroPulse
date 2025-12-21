from pyspark.sql import SparkSession
from pyspark.sql.functions import *
from raw_loader import get_and_write_raw_tables

spark = SparkSession.builder.getOrCreate()

jdbc_driver = spark.conf.get("spark.jdbc.driver")
jdbc_url = spark.conf.get("spark.jdbc.url")
jdbc_user = spark.conf.get("spark.jdbc.user")
jdbc_password = spark.conf.get("spark.jdbc.password")

jdbc_connection_properties = {
    "user": jdbc_user,
    "password": jdbc_password,
    "driver": jdbc_driver
}

raw_table_names = ['users', 'routes', 'vehicles', 'rides', 'payments']
users, routes, vehicles, rides, payments = get_and_write_raw_tables(spark, raw_table_names, jdbc_connection_properties, jdbc_url)
