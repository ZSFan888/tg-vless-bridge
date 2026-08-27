FROM nineseconds/mtg:2
COPY mtg.toml /config.toml
CMD ["run", "/config.toml"]
