#!/bin/sh
set -e

PROXY_HOST="${PROXY_HOST:-${RAILWAY_TCP_PROXY_DOMAIN:-CHANGE_ME.proxy.rlwy.net}}"
PROXY_PORT="${PROXY_PORT:-${RAILWAY_TCP_PROXY_PORT:-0}}"
SECRET="ee65e82630ee51b76b7d4c06bf254d81427777772e6d6963726f736f66742e636f6d"
LINK="https://t.me/proxy?server=${PROXY_HOST}&port=${PROXY_PORT}&secret=${SECRET}"
TGLINK="tg://proxy?server=${PROXY_HOST}&port=${PROXY_PORT}&secret=${SECRET}"

sedesc() {
  printf '%s' "$1" | sed -e 's/[\\&#]/\\&/g'
}

qrencode -o /web/qr.png -s 8 -m 2 "$LINK"

ELINK=$(sedesc "$LINK")
ETGLINK=$(sedesc "$TGLINK")
EHOST=$(sedesc "$PROXY_HOST")
EPORT=$(sedesc "$PROXY_PORT")
ESECRET=$(sedesc "$SECRET")

sed \
  -e "s#{{LINK}}#${ELINK}#g" \
  -e "s#{{TGLINK}}#${ETGLINK}#g" \
  -e "s#{{HOST}}#${EHOST}#g" \
  -e "s#{{PORT}}#${EPORT}#g" \
  -e "s#{{SECRET}}#${ESECRET}#g" \
  /web/index.html.tpl > /web/index.html

httpd -f -p 8080 -h /web &

exec mtg run /config.toml
