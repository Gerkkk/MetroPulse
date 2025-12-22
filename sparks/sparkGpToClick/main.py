from pyspark.sql import SparkSession

if __name__ == "__main__":
    spark = SparkSession.builder.getOrCreate()

    gp_url = spark.conf.get("spark.gp.url")
    gp_user = spark.conf.get("spark.gp.user")
    gp_password = spark.conf.get("spark.gp.password")

    ch_url = spark.conf.get("spark.ch.url")
    ch_user = spark.conf.get("spark.ch.user")
    ch_password = spark.conf.get("spark.ch.password")

    aliases = [x.strip() for x in spark.conf.get("spark.tables").split(",") if x.strip()]

    for alias in aliases:
        gp_query_path = spark.conf.get(f"spark.table.{alias}.gp_query_path")
        ch_table = spark.conf.get(f"spark.table.{alias}.ch_table")

        print(f"\n=== {alias}: {gp_query_path} -> {ch_table} ===")

        with open(gp_query_path, 'r') as f:
            query = f.read().strip().rstrip(";")
            query = f'({query}) as q'

        df = (spark.read.format("jdbc")
              .option("url", gp_url)
              .option("dbtable", query)
              .option("user", gp_user)
              .option("password", gp_password)
              .option("driver", "org.postgresql.Driver")
              .load())

        (df.write.format("jdbc")
           .option("url", ch_url)
           .option("dbtable", ch_table)
           .option("user", ch_user)
           .option("password", ch_password)
           .option("driver", "com.clickhouse.jdbc.ClickHouseDriver")
           .mode("append")
           .save())

        print(f"=== done {alias} ===")

    spark.stop()
