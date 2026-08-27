#!/bin/sh
set -x

xray run -c /etc/xray/config.json &
sleep 2

echo "=== Checking local Xray SOCKS5 port ==="
mtg doctor /config.toml || true

echo "=== Starting mtg ==="
exec mtg run /config.toml
