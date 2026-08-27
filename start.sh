#!/bin/sh
set -x

xray run -c /etc/xray/config.json &
sleep 2

echo "=== Checking local Xray SOCKS5 port ==="
mtg doctor /config.toml || true

echo "=== Starting mtg in debug mode ==="
exec mtg run --debug /config.toml
