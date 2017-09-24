#!/usr/bin/env bash

entry='control.html'

longlived() {
  aws s3 cp \
      --recursive \
      --cache-control 'max-age=31536000' \
      --exclude "$entry" \
      build/ "s3://presenter-origin-1903n6r3puvri/"
}

shortlived() {
    aws s3 cp \
    --cache-control 'max-age=900,s-maxage=60' \
    "build/${entry}" "s3://presenter-origin-1903n6r3puvri/"
}

longlived && shortlived


