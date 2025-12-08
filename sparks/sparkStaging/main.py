from pyspark.sql import SparkSession
from pyspark.sql.functions import *

spark = SparkSession.builder.getOrCreate()

df = spark.read.parquet("s3a://users/data.parquet")