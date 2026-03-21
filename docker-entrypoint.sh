#!/bin/sh
set -eu

DEFAULT_CONFIG="/app/moe-sekai-configs.example.yaml"

mkdir -p /data /data/accounts /data/master /data/versions
export CONFIG_PATH="$DEFAULT_CONFIG"

exec /app/moe-sekai-api
