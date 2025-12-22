from pyspark.sql import SparkSession
from pyspark.sql.functions import *
from pyspark.sql import functions as F

def get_and_write_raw_tables(spark, raw_table_names: list[str], connection_properties, jdbc_url):
    raw_dfs = [None] * len(raw_table_names)
    for ind in range(len(raw_dfs)):
        df = spark.read.parquet(f"s3a://{raw_table_names[ind].lower()}/data.parquet")
        df = df.withColumn("upload_timestamp", current_timestamp())
        raw_dfs[ind] = df

    for df, name in zip(raw_dfs, raw_table_names):
        df.write.jdbc(
            url=jdbc_url,
            table=f"RAW_{name.upper()}",
            mode="append", # "append", "overwrite", "errorifexists", "ignore"
            properties=connection_properties
        )
    return raw_dfs
