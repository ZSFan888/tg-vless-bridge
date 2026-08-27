FROM nineseconds/mtg:2 AS mtgbin

FROM alpine:3.20
RUN apk add --no-cache busybox-extras
COPY --from=mtgbin /mtg /usr/local/bin/mtg
COPY config/mtg.toml /config.toml
COPY web/index.html.tpl /web/index.html.tpl
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
EXPOSE 3128 8080
CMD ["/entrypoint.sh"]
