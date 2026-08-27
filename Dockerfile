FROM nineseconds/mtg:2
COPY config/mtg.toml /config.toml
EXPOSE 3128
CMD ["run", "/config.toml"]
