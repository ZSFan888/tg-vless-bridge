FROM nineseconds/mtg:2
COPY mtg.toml /config.toml
EXPOSE 3128
CMD ["mtg", "run", "/config.toml"]
