#!/bin/bash

if [ "$(uname)" = "Darwin" ]; then
  decode_opt="-D"
else
  decode_opt="-d"
fi

decode() {
  base64 "$decode_opt"
}

usage() {
  echo "Usage $0 " \
    "[--profile <aws-profile>] " \
    "[--output <output-file>] " \
    "[<input-file>] " \
    >&2
}

aws_opts=()
input_file=
output_file=
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
  decode | \
  aws ${aws_opts[@]} kms decrypt \
    --ciphertext-blob fileb:///dev/stdin\
    --query Plaintext \
    --output text | \
  decode \
  > "${output_file:-/dev/stdout}"
