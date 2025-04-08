from awsglue.context import GlueContext
from pyspark.context import SparkContext
from lf_utils import enable_lake_formation

# Initialize with Lake Formation integration
glue_context = GlueContext(SparkContext.getOrCreate())
spark = glue_context.spark_session

# Enable Lake Formation integration
enable_lake_formation(spark)

# Read from raw zone
datasource = glue_context.create_dynamic_frame.from_catalog(
    database="raw_db",
    table_name="sales_data",
    transformation_ctx="datasource"
)

# Transform data
def transform_data(record):
    record["processed_date"] = datetime.now().isoformat()
    return record

transformed = datasource.map(f=transform_data)

# Write to processed zone
glue_context.write_dynamic_frame.from_catalog(
    frame=transformed,
    database="processed_db",
    table_name="sales_processed",
    additional_options={"lakeformation.credentials": "arn:aws:iam::123456789012:role/GlueLFServiceRole"}
)