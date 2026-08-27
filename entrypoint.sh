#!/bin/sh
set -e

PROXY_HOST="${PROXY_HOST:-${RAILWAY_TCP_PROXY_DOMAIN:-CHANGE_ME.proxy.rlwy.net}}"
PROXY_PORT="${PROXY_PORT:-${RAILWAY_TCP_PROXY_PORT:-0}}"
SECRET="ee65e82630ee51b76b7d4c06bf254d81427777772e6d6963726f736f66742e636f6d"
LINK="https://t.me/proxy?server=${PROXY_HOST}&port=${PROXY_PORT}&secret=${SECRET}"
TGLINK="tg://proxy?server=${PROXY_HOST}&port=${PROXY_PORT}&secret=${SECRET}"
QR="https://api.qrserver.com/v1/create-qr-code/?size=220x220&data=${LINK}"

sed \
  -e "s#{{LINK}}#${LINK}#g" \
  -e "s#{{TGLINK}}#${TGLINK}#g" \
  -e "s#{{HOST}}#${PROXY_HOST}#g" \
  -e "s#{{PORT}}#${PROXY_PORT}#g" \
  -e "s#{{SECRET}}#${SECRET}#g" \
  -e "s#{{QR}}#${QR}#g" \
  /web/index.html.tpl > /web/index.html

httpd -f -p 8080 -h /web &

exec mtg run /config.toml
