def enable_lake_formation(spark):
    """Configure Spark session for Lake Formation"""
    spark.conf.set("spark.hadoop.hive.metastore.client.factory.class", 
                 "com.amazonaws.glue.catalog.metastore.AWSGlueDataCatalogHiveClientFactory")
    spark.conf.set("spark.sql.hive.convertMetastoreParquet", "false")