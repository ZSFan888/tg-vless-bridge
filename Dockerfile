# Build mtg from the latest official source.
FROM golang:1.27-alpine AS mtg-builder

RUN apk add --no-cache ca-certificates git
WORKDIR /src
RUN git clone --depth 1 https://github.com/9seconds/mtg.git .
RUN CGO_ENABLED=0 go build -trimpath -mod=readonly -ldflags="-s -w" -tags netgo -o /out/mtg .

# Run mtg alongside the node-info page and local metrics reader.
FROM python:3.12-alpine

RUN addgroup -S mtg && adduser -S mtg -G mtg
COPY --from=mtg-builder /out/mtg /usr/local/bin/mtg
COPY config/mtg.toml /config.toml
COPY web/index.html.tpl /web/index.html.tpl
COPY status-server.py /status-server.py
RUN chown -R mtg:mtg /config.toml /web /status-server.py
USER mtg

EXPOSE 3128 8080 8081
CMD ["/bin/sh", "-c", "mtg run /config.toml & exec python3 /status-server.py"]
