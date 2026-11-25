FROM python:3.12-slim
RUN pip install --no-cache-dir \
      jupyterlab==4.6.6 \
      pyspark-client==4.2.0 \
      pandas==2.3.3 \
      dbt-core==1.12.7 \
      dbt-spark==1.11.1 \
      boto3 \
      "psycopg[binary]"
ENV HOME=/home/lab
RUN mkdir -p /home/lab/work && chmod -R 777 /home/lab
WORKDIR /home/lab/work
EXPOSE 8888
CMD ["jupyter", "lab", "--ip=0.0.0.0", "--port=8888", "--no-browser"]
