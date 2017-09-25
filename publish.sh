#!/usr/bin/env bash

entry='control.html'

content-bucket() {
  aws cloudformation describe-stacks \
    --stack-name presenter \
    --query 'Stacks[0].Outputs[?OutputKey==`"ContentStore"`]  | [0].OutputValue' \
    --output text
}

if [ "$1" = "" ]; then
  origin_bucket=$(content-bucket)
else
  origin_bucket="$1"
fi


longlived() {
  aws s3 cp \
      --recursive \
      --cache-control 'max-age=31536000' \
      --exclude "$entry" \
      build/ "s3://${origin_bucket}/"
}

shortlived() {
    aws s3 cp \
    --cache-control 'max-age=900,s-maxage=60' \
    "build/${entry}" "s3://${origin_bucket}/"
}


longlived && shortlived


