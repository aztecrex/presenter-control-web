#!/bin/bash

usage() {
  echo "Usage $0 " \
    "[--profile <aws-profile>] " \
    "[--key <key-id>] " \
    "[--output <output-file>] " \
    "[<input-file>] " \
    >&2
}

aws_opts=()
input_file=
output_file=
key_id='alias/secrets'
while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    --help|help|-h)
      usage
      exit 3
      ;;
    --profile|-p)
      aws_opts+=(--profile "$2")
      shift
      ;;
    --key|-k)
      key_name="$2"
      shift
      ;;
    --output|-o)
      output_file="$2"
      shift
      ;;
    *)
      if [ "$input_file" = "" ]; then
        input_file="$1"
      else
        echo "Unrecognized option '${key}'" >&2
        usage
        exit 2
      fi
      ;;
  esac
  shift
done
input_file="${input_file:-/dev/stdin}"

cat "$input_file" | \
  aws ${aws_opts[@]} kms encrypt \
    --key-id ${key_id} \
    --plaintext file:///dev/stdin\
    --query CiphertextBlob \
    --output text > "${output_file:-/dev/stdout}"
