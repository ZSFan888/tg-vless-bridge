#!/usr/bin/env python3
import json
import os
import re
import time
import tomllib
import urllib.request
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import quote

TEMPLATE = open("/web/index.html.tpl", encoding="utf-8").read()

with open("/config.toml", "rb") as f:
    _config = tomllib.load(f)
SECRET = _config.get("secret", "")

STATE = {"in_base": 0.0, "out_base": 0.0, "in_last": 0.0, "out_last": 0.0,
         "initialized": False, "at": None}


def render_page():
    host = os.environ.get("PROXY_HOST") or os.environ.get("RAILWAY_TCP_PROXY_DOMAIN") or "CHANGE_ME.proxy.rlwy.net"
    port = os.environ.get("PROXY_PORT") or os.environ.get("RAILWAY_TCP_PROXY_PORT") or "0"
    public_link = f"https://t.me/proxy?server={host}&port={port}&secret={SECRET}"
    tg_link = f"tg://proxy?server={host}&port={port}&secret={SECRET}"
    qr = "https://api.qrserver.com/v1/create-qr-code/?size=220x220&data=" + quote(public_link, safe="")
    return (TEMPLATE.replace("{{HOST}}", host).replace("{{PORT}}", port).replace("{{SECRET}}", SECRET)
            .replace("{{LINK}}", public_link).replace("{{TGLINK}}", tg_link).replace("{{QR}}", qr))


def metric_value(text, names):
    total = 0.0
    found = False
    for line in text.splitlines():
        if line.startswith("#"):
            continue
        for name in names:
            if line.startswith(name + "{") or line.startswith(name + " "):
                try:
                    total += float(line.rsplit(" ", 1)[1])
                    found = True
                except (IndexError, ValueError):
                    pass
                break
    return total if found else 0.0


def scan_traffic_fallback(text):
    inbound = outbound = 0.0
    for line in text.splitlines():
        if line.startswith("#") or "traffic" not in line.lower() or "bytes" not in line.lower():
            continue
        try:
            value = float(line.rsplit(" ", 1)[1])
        except (IndexError, ValueError):
            continue
        lower = line.lower()
        if any(k in lower for k in ('direction="to_client"', 'direction="sent"', 'direction="egress"', 'direction="out"')):
            outbound += value
        elif any(k in lower for k in ('direction="from_client"', 'direction="received"', 'direction="ingress"', 'direction="in"')):
            inbound += value
    return inbound, outbound


def cumulative(raw_in, raw_out):
    if not STATE["initialized"]:
        STATE["in_last"] = raw_in
        STATE["out_last"] = raw_out
        STATE["initialized"] = True
    if raw_in < STATE["in_last"]:
        STATE["in_base"] += STATE["in_last"]
    if raw_out < STATE["out_last"]:
        STATE["out_base"] += STATE["out_last"]
    STATE["in_last"] = raw_in
    STATE["out_last"] = raw_out
    return STATE["in_base"] + raw_in, STATE["out_base"] + raw_out


def metrics():
    now = time.time()
    try:
        with urllib.request.urlopen("http://127.0.0.1:8081/metrics", timeout=2) as response:
            text = response.read().decode("utf-8", "replace")
        clients = metric_value(text, ["mtg_client_connections", "mtg_clients_connected"])
        upstream = metric_value(text, ["mtg_telegram_connections", "mtg_telegram_connected"])
        inbound = metric_value(text, ["mtg_telegram_traffic_received_bytes", "mtg_traffic_received_bytes", "mtg_telegram_traffic_in_bytes"])
        outbound = metric_value(text, ["mtg_telegram_traffic_sent_bytes", "mtg_traffic_sent_bytes", "mtg_telegram_traffic_out_bytes"])
        if inbound == 0 and outbound == 0:
            inbound, outbound = scan_traffic_fallback(text)

        total_in, total_out = cumulative(inbound, outbound)

        elapsed = max(now - STATE["at"], 1) if STATE["at"] else 0
        rate_in = max(total_in - STATE.get("rate_in_prev", total_in), 0) / elapsed if elapsed else 0
        rate_out = max(total_out - STATE.get("rate_out_prev", total_out), 0) / elapsed if elapsed else 0
        STATE["rate_in_prev"] = total_in
        STATE["rate_out_prev"] = total_out
        STATE["at"] = now

        return {"ok": True, "clients": int(clients), "upstream": int(upstream),
                "in_bytes": int(total_in), "out_bytes": int(total_out),
                "in_rate": rate_in, "out_rate": rate_out, "updated_at": int(now)}
    except Exception as exc:
        return {"ok": False, "error": str(exc), "updated_at": int(now)}


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == "/api/status":
            body = json.dumps(metrics()).encode()
            self.send_response(200)
            self.send_header("Content-Type", "application/json; charset=utf-8")
            self.send_header("Cache-Control", "no-store")
            self.send_header("Content-Length", str(len(body)))
            self.end_headers()
            self.wfile.write(body)
        elif self.path in ("/", "/index.html"):
            body = render_page().encode()
            self.send_response(200)
            self.send_header("Content-Type", "text/html; charset=utf-8")
            self.send_header("Cache-Control", "no-store")
            self.send_header("Content-Length", str(len(body)))
            self.end_headers()
            self.wfile.write(body)
        else:
            self.send_error(404)

    def log_message(self, format, *args):
        pass


ThreadingHTTPServer(("0.0.0.0", 8080), Handler).serve_forever()
