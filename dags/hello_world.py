"""Says hello to every service. Trigger it by hand in the Airflow UI."""
from airflow.sdk import dag, task


@dag(schedule=None, catchup=False, tags=["hello"])
def hello_world():
    @task
    def hello_postgres():
        from airflow.providers.postgres.hooks.postgres import PostgresHook

        print(PostgresHook().get_first("SELECT 'Hello from Postgres', version()"))

    @task
    def hello_s3():
        from airflow.providers.amazon.aws.hooks.s3 import S3Hook

        S3Hook().load_string("Hello from S3", key="hello.txt", bucket_name="lakehouse", replace=True)
        print(S3Hook().read_key(key="hello.txt", bucket_name="lakehouse"))

    @task.pyspark(conn_id="spark_connect_default")
    def hello_spark(spark):
        spark.sql("CREATE TABLE IF NOT EXISTS main.default.hello_airflow (message STRING, at TIMESTAMP) USING DELTA")
        spark.sql("INSERT INTO main.default.hello_airflow VALUES ('Hello from Airflow', current_timestamp())")
        spark.table("main.default.hello_airflow").show(truncate=False)

    @task.bash(cwd="/opt/airflow/dbt/hello_world")
    def hello_dbt():
        return "dbt build"

    [hello_postgres(), hello_s3()] >> hello_spark() >> hello_dbt()


hello_world()
