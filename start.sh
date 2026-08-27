#!/bin/sh
xray run -c /etc/xray/config.json &
sleep 2
exec mtg run /config.toml
