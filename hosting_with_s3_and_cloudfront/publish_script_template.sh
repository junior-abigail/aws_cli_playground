#!/bin/bash

if [[ $_ != $0 ]]; then
  echo "You must execute script instead of sourcing it."
  return 1
fi

function validate_input {
  if [ -z "$1" ]; then
    echo "Usage:
    publish_to_${BUCKET_NAME}.sh <directory>"
    echo "Syncs the contents of the specified <directory> with the root"      \
    "directory of the s3 bucket linked to this script. Then creates an"       \
    "invalidation for the cloudfront distribution caching the contents of"    \
    "the bucket in order to push the changes to the edge locations."
    exit 1
  fi

  if [ ! -d "${DOLLAR}1" ]; then
    echo "${DOLLAR}1 is not a directory"
    exit 1
  fi

  export DIR=${DOLLAR}1
}

function sync_contents {
  echo "Uploading contents of ${DOLLAR}DIR to ${BUCKET_NAME}"
  aws s3 sync ${DOLLAR}DIR s3://${BUCKET_NAME}
}

function update_cache {
  echo "Creating cloudfront invalidation (cache update)"
  aws cloudfront create-invalidation \
    --distribution-id ${DISTRIBUTION_ID} \
    --paths "/"
}

function run {
  validate_input $1
  sync_contents
  update_cache
  echo "Distribution update started. Process may take a few minutes." \
  "Remember that the public url is $DISTRIBUTION_DOMAIN"
}

run $1
