"""Creates the S3 bucket, the catalog "main" and the schema "main.default" if they are missing."""
import json
import os
import urllib.error
import urllib.request

import boto3

BUCKET = "lakehouse"

s3 = boto3.client("s3")
if BUCKET not in [b["Name"] for b in s3.list_buckets()["Buckets"]]:
    s3.create_bucket(Bucket=BUCKET)
print("bucket ready:", BUCKET)


def create(kind, body):
    request = urllib.request.Request(
        f"{os.environ['UNITY_CATALOG_URL']}/api/2.1/unity-catalog/{kind}",
        json.dumps(body).encode(),
        {"Content-Type": "application/json"},
    )
    try:
        urllib.request.urlopen(request)
    except urllib.error.HTTPError as error:
        message = error.read().decode()
        if "ALREADY_EXISTS" not in message:
            raise SystemExit(f"{kind}: {message}")
    print("ready:", kind, body["name"])


create("catalogs", {"name": "main", "storage_root": f"s3://{BUCKET}/main"})
create("schemas", {"name": "default", "catalog_name": "main"})
