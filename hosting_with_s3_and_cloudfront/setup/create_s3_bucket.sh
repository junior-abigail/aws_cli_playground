#!/bin/bash

function s3_bucket_create {
  echo "Creating bucket $BUCKET_NAME"
	aws s3api create-bucket --bucket $BUCKET_NAME
}

function s3_bucket_make_public {
  echo "Adding public read policy to bucket $BUCKET_NAME"
	POLICY=$(envsubst < ./json_templates/s3_bucket_public_read.json)
	aws s3api put-bucket-policy --bucket $BUCKET_NAME --policy "$POLICY"
}

function cloudfront_create_distribution {
  echo "Creating cloudfront distribution"
  DISTRIBUTION_CONFIG=$(envsubst < ./json_templates/cloudfront_distribution.json)
  aws cloudfront create-distribution \
    --distribution-config "$DISTRIBUTION_CONFIG"
}

function set_env_variables {
  export BUCKET_NAME=$1
  export CALLER_REF="${BUCKET_NAME}_$(date -u +%FT%TZ)"
}

function validate {
  if [ "${BASH_SOURCE[0]}" -ef "$0" ]
  then
      echo "You must source this script"
      exit 1
  fi
  if [ -z "$1" ]; then
    echo "Usage:
    source create_s3_bucket.sh <bucket_name>"
    echo "Creates an S3 bucket with the specified <bucket_name> and grants" \
    "public read access to the bucket's contents. Then creates a cloudfront" \
    "distribution for the bucket configured to redirect http traffic to" \
    "https. The resulting bucket can then be used to host a web application," \
    "by uploading the static files to the bucket with an entry point of" \
    "index.html. The contents of the bucket are publicly accessible by" \
    "visiting the cloudfront distribution's domain name url generated when" \
    "the distribution is created."
    return 1
  fi
}

function run {
  validate $1
  if [ $? -ne 0 ]; then return; fi;
  set_env_variables $1
  s3_bucket_create
  if [ $? -ne 0 ]; then return; fi;
  s3_bucket_make_public
  if [ $? -ne 0 ]; then return; fi;
  cloudfront_create_distribution
}

run $1
