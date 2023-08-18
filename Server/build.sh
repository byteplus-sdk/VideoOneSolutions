#!/usr/bin/env bash
RUN_NAME="videoone"

set -e
if [ -d "output" ]; then
  rm -rf output
  mkdir output
fi


go build -o output/bin/${RUN_NAME} ./cmd

mkdir -p output/conf
cp conf/* output/conf
cp script/* output/
chmod +x output/bootstrap.sh
chmod +x output/bin/${RUN_NAME}