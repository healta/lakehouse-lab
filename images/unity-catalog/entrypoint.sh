#!/bin/sh
# Unity Catalog reads its settings from files, so write them from the container's environment.
set -eu
mkdir -p etc/conf

cat > etc/conf/hibernate.properties <<PROPS
hibernate.connection.driver_class=org.postgresql.Driver
hibernate.connection.url=jdbc:postgresql://${PGHOST}:5432/${PGDATABASE}
hibernate.connection.user=${PGUSER}
hibernate.connection.password=${PGPASSWORD}
hibernate.hbm2ddl.auto=update
hibernate.archive.autodetection=class
PROPS

cat > etc/conf/server.properties <<PROPS
server.env=dev
server.authorization=disable
s3.bucketPath.0=s3://${S3_BUCKET}
s3.region.0=us-east-1
s3.awsRoleArn.0=arn:aws:iam::000000000000:role/lakehouse
s3.credentialGenerator.0=RustfsCredentials
PROPS

exec java ${JAVA_OPTS:-} -cp 'classes:jars/*' io.unitycatalog.server.UnityCatalogServer
