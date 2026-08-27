FROM nineseconds/mtg:2 AS mtgbin
FROM teddysun/xray:latest
COPY --from=mtgbin /mtg /usr/local/bin/mtg
COPY xray-config.json /etc/xray/config.json
COPY mtg.toml /config.toml
COPY start.sh /start.sh
RUN chmod +x /start.sh
EXPOSE 3128
CMD ["/start.sh"]
