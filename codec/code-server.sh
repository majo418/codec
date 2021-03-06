#!/bin/bash

echo "CodecMain: copy new config..."
mkdir -p /home/codec/.config/code-server
rm -rf /home/codec/.config/code-server/config.yaml
cp /home/codec/ws/.codec/code-server.yaml /home/codec/.config/code-server/config.yaml

source /etc/environment
source /home/codec/ws/.codec/codeinit.sh

echo "CodecMain: Execute code-server..."

rm -rf /tmp/*
code \
    --port 8080 \
    --host 0.0.0.0 \
    /home/codec/ws/.codec/default.code-workspace

touch /home/codec/ws/.codec/code-server.yaml
