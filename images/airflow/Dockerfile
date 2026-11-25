FROM apache/airflow:slim-3.4.0-python3.12
RUN pip install --no-cache-dir \
      "apache-airflow==3.4.0" \
      apache-airflow-providers-amazon \
      apache-airflow-providers-apache-spark \
      apache-airflow-providers-postgres \
      --constraint https://raw.githubusercontent.com/apache/airflow/constraints-3.4.0/constraints-3.12.txt \
    # must match the Spark server, which does not support pandas 3 yet
    && pip install --no-cache-dir pyspark-client==4.2.0 pandas==2.3.3 \
    # dbt needs an older pathspec than the constraints; pip check proves Airflow still accepts it
    && pip install --no-cache-dir "apache-airflow==3.4.0" dbt-core==1.12.7 dbt-spark==1.11.1 \
    && pip check
