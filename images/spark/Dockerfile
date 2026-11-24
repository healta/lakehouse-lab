# Spark Connect server with Delta Lake, Unity Catalog and S3 support.
# These versions belong together. Check the Delta and Unity Catalog release notes before changing one.
FROM apache/spark:4.2.0-scala2.13-java21-ubuntu AS base
USER root

FROM base AS jars
ADD https://github.com/coursier/coursier/releases/download/v2.1.27/coursier /usr/local/bin/cs
# hadoop-aws normally drags in the whole 690 MB AWS SDK. Only the parts S3A uses are fetched instead.
RUN chmod +x /usr/local/bin/cs && mkdir /jars && cs fetch \
      io.delta:delta-spark_4.2_2.13:4.4.1 \
      io.unitycatalog:unitycatalog-spark_4.2_2.13:0.7.0 \
      org.apache.hadoop:hadoop-aws:3.5.0 \
      software.amazon.awssdk:s3:2.35.4 \
      software.amazon.awssdk:s3-transfer-manager:2.35.4 \
      software.amazon.awssdk:sts:2.35.4 \
      software.amazon.awssdk:kms:2.35.4 \
      software.amazon.awssdk:apache-client:2.35.4 \
      software.amazon.awssdk:netty-nio-client:2.35.4 \
      --exclude software.amazon.awssdk:bundle \
      --exclude org.slf4j:slf4j-reload4j \
    | while read -r jar; do \
        name=$(basename "$jar" | sed -E 's/-[0-9][^-]*(-.*)?\.jar$//'); \
        ls /opt/spark/jars | grep -qE "^${name}-[0-9]" || cp "$jar" /jars/; \
      done \
    && ls /jars

FROM base
# Same Python minor version as Airflow and Jupyter: Spark Connect needs that for Python UDFs.
COPY --from=ghcr.io/astral-sh/uv:0.13.10 /uv /usr/local/bin/uv
ENV UV_PYTHON_INSTALL_DIR=/opt/uv-python UV_NO_CACHE=1
RUN uv venv --python 3.12 /opt/python \
    && uv pip install --python /opt/python/bin/python pandas==2.3.3 pyarrow==22.0.0 numpy==2.3.5
ENV PYSPARK_PYTHON=/opt/python/bin/python SPARK_NO_DAEMONIZE=1
COPY --from=jars /jars/ /opt/spark/jars/
COPY spark-defaults.conf /opt/spark/conf/
USER spark
EXPOSE 15002 4040
ENTRYPOINT ["/opt/spark/sbin/start-connect-server.sh"]
