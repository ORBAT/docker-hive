#!/bin/bash
set -e

if [[ -z "$METASTORE_URI" || -z "$S3_SECRET_ACCESS_KEY" || -z "$S3_ACCESS_KEY" ]]; then
    echo "missing METASTORE_URI, S3_SECRET_ACCESS_KEY or S3_ACCESS_KEY"
    exit 1
fi

tables=$(hive --hiveconf hive.metastore.uris=$METASTORE_URI --hiveconf fs.s3a.secret.key="$S3_SECRET_ACCESS_KEY" --hiveconf fs.s3a.access.key=$S3_ACCESS_KEY --silent \
-e "show tables;" 2>/dev/null)

echo "found tables: $tables"

if [[ -z "$tables" ]]; then
    echo "no tables found"
    exit 2
fi

for table in ${tables}; do
  echo "repairing partitions for $table"
  hive --hiveconf hive.metastore.uris=$METASTORE_URI --hiveconf fs.s3a.secret.key="$S3_SECRET_ACCESS_KEY" --hiveconf fs.s3a.access.key=$S3_ACCESS_KEY -e "msck repair table ${table};"
done