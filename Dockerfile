FROM nineseconds/mtg:2 AS mtgbin

FROM python:3.12-alpine
COPY --from=mtgbin /mtg /usr/local/bin/mtg
COPY config/mtg.toml /config.toml
COPY web/index.html.tpl /web/index.html.tpl
COPY status-server.py /status-server.py
EXPOSE 3128 8080 8081
CMD ["/bin/sh", "-c", "mtg run /config.toml & exec python3 /status-server.py"]
