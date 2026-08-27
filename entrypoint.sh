#!/bin/sh
set -e

PROXY_HOST="${PROXY_HOST:-${RAILWAY_TCP_PROXY_DOMAIN:-CHANGE_ME.proxy.rlwy.net}}"
PROXY_PORT="${PROXY_PORT:-${RAILWAY_TCP_PROXY_PORT:-0}}"
SECRET="ee184a82a5a62c20392baafa444cbafe997777772e62696e672e636f6d"
LINK="https://t.me/proxy?server=${PROXY_HOST}&port=${PROXY_PORT}&secret=${SECRET}"
QR="https://api.qrserver.com/v1/create-qr-code/?size=220x220&data=${LINK}"

sed \
  -e "s#{{LINK}}#${LINK}#g" \
  -e "s#{{HOST}}#${PROXY_HOST}#g" \
  -e "s#{{PORT}}#${PROXY_PORT}#g" \
  -e "s#{{SECRET}}#${SECRET}#g" \
  -e "s#{{QR}}#${QR}#g" \
  /web/index.html.tpl > /web/index.html

httpd -f -p 8080 -h /web &

exec mtg run /config.toml
