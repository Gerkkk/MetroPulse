from pyspark.sql import SparkSession
from pyspark.sql.functions import *
from pyspark.sql import functions as F
import jaydebeapi
import uuid

def get_unique_col_by_table(table):
    match table:
        case "s_positions":
            return "id"
        case "positions":
            return "id"
        case _:
            raise RuntimeError("Got unexpeted table name to get unique field")

def get_rank_col_by_table(table):
    match table:
        case "positions":
            return "created_at"
        case "s_positions":
            return "created_at"
        case "payments":
            return "created_at"
        case "s_payemnts":
            return "created_at"
        case _:
            return "__ts_ms"
            #raise RuntimeError("Got unexpeted table name to get unique field")

def add_cur_valid(df, table):
    if get_rank_col_by_table(table) != None:
        df = df.withColumn("valid_from", F.col(get_rank_col_by_table(table)))
    else:
        df = df.withColumn("valid_from", F.current_timestamp())
    df = df.withColumn("valid_to", F.lit("3000-01-01 00:00:00").cast("timestamp"))
    df = df.withColumn("is_current", F.lit(True))

    return df

def wrap_squates(s):
    return "'" + str(s) + "'"

def get_sat_core_table(table):
    return "s_" + table

def get_hub_core_table(table):
    return "h_" + table

def get_link_core_table(table):
    return "l_" + table

def set_invalid(df, dwh, table: str, valid_tss):
    col1="is_current"
    col2 = "valid_to"
    col_chk="valid_from"
    unique = get_unique_col_by_table(table)
    
    cur_ts = F.current_timestamp()
    for id, valid in valid_tss.items():
        df = df.withColumn(
            col1,
            F.when((F.col(unique) == id) & (F.col(col_chk) < valid["ts"]), False).otherwise(True)
        )
        df = df.withColumn(
            col2,
            F.when((F.col(unique) == id) & (F.col(col_chk) < valid["ts"]), cur_ts).otherwise(F.col(col2))
        )

        dwh.raw_query(f"UPDATE {get_sat_core_table(table)} SET {col1} = False, {col2} = current_timestamp WHERE {unique} = {wrap_squates(id)} AND {col_chk} < {wrap_squates(valid['ts'])}")
    return df

def sql_gen_one_of(col: str, values: list):
    values = [f"'{val}'" for val in values]
    delim = f" OR {col} = "
    return f"{col} = " + delim.join(values)

def get_distinct_col_as_list(df, col):
    return [row[col] for row in df.distinct().select(col).collect()]


class DWHWorker:
    def __init__(self, spark, jdbc_connection_properties, jdbc_url, jdbc_jar):
        self.spark = spark
        self.con_properties = jdbc_connection_properties
        self.con_url = jdbc_url
        self.conn = jaydebeapi.connect(jdbc_connection_properties["driver"],
                                       jdbc_url,
                                       jdbc_connection_properties,
                                       jdbc_jar)

    def store(self, df, table):
        df.write.jdbc(
            url=self.con_url,
            table=table,
            mode="append", # "append", "overwrite", "errorifexists", "ignore"
            properties=self.con_properties
        )
    
    def load(self, table):
        return self.spark.read.jdbc(
            url=self.con_url,
            table=table,
            properties=self.con_properties
            )

    def query(self, query: str):
        return self.spark.read.jdbc(
            url=self.con_url,
            table=f"({query}) as q",
            properties=self.con_properties
            )
            
    
    def raw_query(self, query: str):
        cursor = self.conn.cursor()
        cursor.execute(query)
        cursor.close()

    def get_cur_valid_tss_by_table(self, df, table: str, ids: list):
        unique = get_unique_col_by_table(table)
        rank = get_rank_col_by_table(table)

        add_df = df.groupBy(unique).agg(F.max(rank).alias(rank))
        match table:
            case "s_positions":
                qdf = self.query(f"SELECT MAX({rank}) as {rank}, {unique} FROM {table} WHERE {sql_gen_one_of(unique, ids)} GROUP BY {unique}")
                add_df = add_df.unionByName(qdf)
            case _:
                raise RuntimeError("Got unexpeted column to get valid ts")

        tss = add_df.groupBy(unique).agg(F.max(rank).alias(rank)).collect()

        valid_tss = {ts[unique]: {"ts": ts[rank], "unique": ts[unique]} for ts in tss}
        return valid_tss

def set_or_create_ids(df, dwh, table: str, id_field: str):
    hub = dwh.load(table).select("id", id_field)
    df = df.join(hub, "postition_event_id", how="left_outer")

    df = df.withColumn("id", F.coalesce(
        F.col("id"),
        F.uuid()
        )
    )
    return df