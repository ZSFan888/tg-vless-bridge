#!/usr/bin/env python3
import json
import os
import re
import time
import urllib.request
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import quote

HOST = os.environ.get("PROXY_HOST") or os.environ.get("RAILWAY_TCP_PROXY_DOMAIN") or "CHANGE_ME.proxy.rlwy.net"
PORT = os.environ.get("PROXY_PORT") or os.environ.get("RAILWAY_TCP_PROXY_PORT") or "0"
SECRET = "ee184a82a5a62c20392baafa444cbafe997777772e62696e672e636f6d"
PUBLIC_LINK = f"https://t.me/proxy?server={HOST}&port={PORT}&secret={SECRET}"
TG_LINK = f"tg://proxy?server={HOST}&port={PORT}&secret={SECRET}"
QR = "https://api.qrserver.com/v1/create-qr-code/?size=220x220&data=" + quote(PUBLIC_LINK, safe="")
TEMPLATE = open("/web/index.html.tpl", encoding="utf-8").read()
PAGE = (TEMPLATE.replace("{{HOST}}", HOST).replace("{{PORT}}", PORT).replace("{{SECRET}}", SECRET)
        .replace("{{LINK}}", PUBLIC_LINK).replace("{{TGLINK}}", TG_LINK).replace("{{QR}}", QR))
last = {"at": None, "in": 0.0, "out": 0.0}

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

def metrics():
    global last
    now = time.time()
    try:
        with urllib.request.urlopen("http://127.0.0.1:8081/metrics", timeout=2) as response:
            text = response.read().decode("utf-8", "replace")
        clients = metric_value(text, ["mtg_client_connections", "mtg_clients_connected"])
        upstream = metric_value(text, ["mtg_telegram_connections", "mtg_telegram_connected"])
        inbound = metric_value(text, ["mtg_telegram_traffic_received_bytes", "mtg_traffic_received_bytes", "mtg_telegram_traffic_in_bytes"])
        outbound = metric_value(text, ["mtg_telegram_traffic_sent_bytes", "mtg_traffic_sent_bytes", "mtg_telegram_traffic_out_bytes"])
        if inbound == 0 and outbound == 0:
            for line in text.splitlines():
                if line.startswith("#") or "traffic" not in line:
                    continue
                try:
                    value = float(line.rsplit(" ", 1)[1])
                except (IndexError, ValueError):
                    continue
                if 'direction="to_client"' in line:
                    outbound += value
                elif 'direction="from_client"' in line:
                    inbound += value
        elapsed = max(now - last["at"], 1) if last["at"] else 0
        rate_in = max(inbound - last["in"], 0) / elapsed if elapsed else 0
        rate_out = max(outbound - last["out"], 0) / elapsed if elapsed else 0
        last = {"at": now, "in": inbound, "out": outbound}
        return {"ok": True, "clients": int(clients), "upstream": int(upstream), "in_bytes": int(inbound), "out_bytes": int(outbound), "in_rate": rate_in, "out_rate": rate_out, "updated_at": int(now)}
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
            body = PAGE.encode()
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
