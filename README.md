# MTProto Proxy (mtg)

A minimal, self-hosted Telegram MTProto proxy running on [mtg](https://github.com/9seconds/mtg), deployed on Railway.

## Structure

- `Dockerfile` — builds the mtg image and copies in the config
- `config/mtg.toml` — mtg configuration (secret, bind address)

## Deployment

This repo auto-deploys to Railway on every push to `main`. The container listens on port `3128`, exposed publicly via Railway's TCP Proxy feature (required since MTProto is raw TCP, not HTTP).

## Connecting

In Telegram, add an MTProto proxy using:

- **Server**: the hostname from Railway's TCP Proxy settings
- **Port**: the external port assigned by Railway's TCP Proxy
- **Secret**: the value of `secret` in `config/mtg.toml`

Or open a one-tap link:

```
https://t.me/proxy?server=<host>&port=<port>&secret=<secret>
```
