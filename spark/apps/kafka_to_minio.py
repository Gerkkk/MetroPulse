from pyspark.sql import SparkSession
from pyspark.sql.functions import from_json, col, to_date
from pyspark.sql.functions import get_json_object
from pyspark.sql.functions import udf
from pyspark.sql.types import StructType, StructField, StringType, IntegerType, TimestampType
from pyspark.sql.types import *

payments_schema = StructType([
    StructField("payment_id", StringType(), False),
    StructField("ride_id", StringType(), True),
    StructField("user_id", IntegerType(), True),
    StructField("amount", DecimalType(precision=10, scale=2), True),
    StructField("payment_method", StringType(), True),
    StructField("status", StringType(), True),
    StructField("created_at", LongType(), True),
    StructField("__op", StringType(), True),
    StructField("__table", StringType(), True),
    StructField("__ts_ms", LongType(), True)
])

rides_schema = StructType([
    StructField("ride_id", StringType(), False),
    StructField("user_id", IntegerType(), True),
    StructField("route_id", IntegerType(), True),
    StructField("vehicle_id", IntegerType(), True),
    StructField("start_time", LongType(), True),
    StructField("end_time", LongType(), True),
    StructField("fare_amount", DecimalType(10,2), True),
    StructField("__op", StringType(), True),
    StructField("__table", StringType(), True),
    StructField("__ts_ms", LongType(), True)
])

routes_schema = StructType([
    StructField("route_id", IntegerType(), False),
    StructField("route_number", StringType(), True),
    StructField("vehicle_type", StringType(), True),
    StructField("base_fare", DecimalType(10,2), True),
    StructField("__op", StringType(), True),
    StructField("__table", StringType(), True),
    StructField("__ts_ms", LongType(), True)
])

users_schema = StructType([
    StructField("user_id", IntegerType(), False),
    StructField("name", StringType(), True),
    StructField("email", StringType(), True),
    StructField("created_at", LongType(), True),
    StructField("city", StringType(), True),
    StructField("__op", StringType(), True),
    StructField("__table", StringType(), True),
    StructField("__ts_ms", LongType(), True)
])

vehicles_schema = StructType([
    StructField("vehicle_id", IntegerType(), False),
    StructField("route_id", IntegerType(), True),
    StructField("licence_plate", StringType(), True),
    StructField("capacity", IntegerType(), True),
    StructField("__op", StringType(), True),
    StructField("__table", StringType(), True),
    StructField("__ts_ms", LongType(), True)
])

gps_schema = StructType([
    StructField("event_id", StringType(), False),
    StructField("vehicle_id", IntegerType(), False),
    StructField("route_number", StringType(), True),
    StructField("event_type", StringType(), True),
    StructField("coordinates", StructType([
        StructField("latitude", DoubleType(), True),
        StructField("longitude", DoubleType(), True)
    ]), True),
    StructField("speed_kmh", DoubleType(), True),
    StructField("passengers_estimated", IntegerType(), True)
])

topics_schemas = [
    ("pg.public.payments", payments_schema, "payments"),
    ("pg.public.rides", rides_schema, "rides"),
    ("pg.public.routes", routes_schema, "routes"),
    ("pg.public.users", users_schema, "users"),
    ("pg.public.vehicles", vehicles_schema, "vehicles"),
    ("vehicle_positions", gps_schema, "vehicle_positions")
]

spark = SparkSession.builder.appName("KafkaToMinio").getOrCreate()
kafka_brokers = "kafka:9092"
minio_endpoint = "s3a://minio:9000/kafka"
spark._jsc.hadoopConfiguration().set("fs.s3a.access.key", "admin")
spark._jsc.hadoopConfiguration().set("fs.s3a.secret.key", "admin1234")
spark._jsc.hadoopConfiguration().set("fs.s3a.endpoint", "http://minio:9000")
spark._jsc.hadoopConfiguration().set("fs.s3a.path.style.access", "true")

def process_topic(topic_name, schema, target):
    bucket_name = "kafka"

    df_raw = spark.read \
        .format("kafka") \
        .option("kafka.bootstrap.servers", "kafka:9092") \
        .option("subscribe", topic_name) \
        .option("startingOffsets", "earliest") \
        .load()

    df_json = df_raw.selectExpr("CAST(value AS STRING) as json")

    if topic_name != "vehicle_positions":
        df_parsed = df_json.selectExpr("get_json_object(json, '$.payload') as payload_json")
        df_parsed = df_parsed.select(from_json(col("payload_json"), schema).alias("w")).select("w.*")
    else:
        df_parsed = df_json.selectExpr("get_json_object(json, '$.payload_json') as payload_json")

    if topic_name == "pg.public.payments":
        df_parsed = df_parsed.withColumn("amount", col("amount").cast("decimal(10,2)"))
    elif topic_name == "pg.public.rides":
        df_parsed = df_parsed.withColumn("fare_amount", col("fare_amount").cast("decimal(10,2)"))
    elif topic_name == "pg.public.routes":
        df_parsed = df_parsed.withColumn("base_fare", col("base_fare").cast("decimal(10,2)"))

    df_parsed.show(truncate=False)

    if "__ts_ms" in df_parsed.columns:
        df_parsed = df_parsed.withColumn(
            "day",
            to_date((col("__ts_ms") / 1000).cast("timestamp"))
        )
    else:
        from pyspark.sql.functions import current_date
        df_parsed = df_parsed.withColumn("day", current_date())

    df_parsed.write \
        .mode("append") \
        .partitionBy("day") \
        .parquet(f"s3a://{bucket_name}/{target}")

for topic, schema, target in topics_schemas:
    process_topic(topic, schema, target)
