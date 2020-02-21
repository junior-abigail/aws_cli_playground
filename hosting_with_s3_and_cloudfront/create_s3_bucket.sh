#!/bin/bash

if [[ $_ != $0 ]]; then
  echo "You must execute script instead of sourcing it."
  return 1
fi

function validate_input {
  if [ -z "$1" ]; then
    echo "Usage:
    create_s3_bucket.sh <bucket_name>"
    echo "Creates an S3 bucket with the specified <bucket_name> and grants"   \
    "public read access to the bucket's contents. Then creates a cloudfront"  \
    "distribution for the bucket configured to redirect http traffic to"      \
    "https. The resulting bucket can then be used to host a web application," \
    "by uploading the static files to the bucket with an entry point of"      \
    "index.html. The contents of the bucket are publicly accessible by"       \
    "visiting the cloudfront distribution's domain name url generated when"   \
    "the distribution is created."
    exit 1
  fi

  if [ ! -z "$(aws s3 ls | grep $1)" ]; then
    echo "The bucket $1 already exist"
    exit 1
  fi
  
  export BUCKET_NAME=$1
  export CALLER_REF="${BUCKET_NAME}_$(date -u +%FT%TZ)"
}

function s3_bucket_create {
  echo "Creating bucket $BUCKET_NAME"
	aws s3api create-bucket --bucket $BUCKET_NAME
}

function s3_bucket_make_public {
  echo "Adding public read policy to bucket $BUCKET_NAME"
	POLICY=$(envsubst < ${BASH_SOURCE%/*}/json_templates/s3_bucket_public_read.json)
	aws s3api put-bucket-policy --bucket $BUCKET_NAME --policy "$POLICY"
}

function cloudfront_create_distribution {
  echo "Creating cloudfront distribution"
  DISTRIBUTION_CONFIG=$(envsubst < ${BASH_SOURCE%/*}/json_templates/cloudfront_distribution.json)
  CREATED_DISTRIBUTION=$(aws cloudfront create-distribution \
    --distribution-config "$DISTRIBUTION_CONFIG")
  echo $CREATED_DISTRIBUTION > distribution.json
  export DISTRIBUTION_ID=$(echo $CREATED_DISTRIBUTION | jq '.Distribution.Id')
  export DISTRIBUTION_DOMAIN=$(echo $CREATED_DISTRIBUTION | jq '.Distribution.DomainName')
  echo "Distribution created. Public url => $DISTRIBUTION_DOMAIN"
}

function generate_publish_script {
  echo "Generating helper script for publishing to bucket."
  export DOLLAR=$
  SCRIPT_FILE=$(pwd)/publish_to_${BUCKET_NAME}.sh
  envsubst < ${BASH_SOURCE%/*}/publish_script_template.sh > $SCRIPT_FILE
  echo "Succefully created script $SCRIPT_FILE"
}

function run {
  set -e
  validate_input $1
  s3_bucket_create
  s3_bucket_make_public
  cloudfront_create_distribution
  generate_publish_script
  set +e
}

run $1
