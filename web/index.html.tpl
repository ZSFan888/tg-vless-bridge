<!DOCTYPE html>
<html lang="zh">
<head>
<meta charset="UTF-8">
<title>MTProto 代理信息</title>
<style>
  body { font-family: -apple-system, sans-serif; background:#0f1115; color:#eee; display:flex; flex-direction:column; align-items:center; padding:40px 16px; }
  .card { background:#1a1d24; border-radius:12px; padding:24px 32px; max-width:420px; width:100%; box-shadow:0 4px 20px rgba(0,0,0,.3); }
  h1 { font-size:18px; margin-top:0; }
  .row { margin:10px 0; word-break:break-all; }
  .label { color:#8a8f98; font-size:12px; text-transform:uppercase; letter-spacing:.05em; }
  a.btn { display:block; text-align:center; background:#2ea6ff; color:#fff; text-decoration:none; padding:12px; border-radius:8px; margin-top:16px; font-weight:600; }
  img { display:block; margin:16px auto 0; border-radius:8px; }
</style>
</head>
<body>
  <div class="card">
    <h1>MTProto 代理连接信息</h1>
    <div class="row"><div class="label">Server</div>{{HOST}}</div>
    <div class="row"><div class="label">Port</div>{{PORT}}</div>
    <div class="row"><div class="label">Secret</div>{{SECRET}}</div>
    <img src="{{QR}}" alt="QR code" width="220" height="220">
    <a class="btn" href="{{LINK}}">在 Telegram 中打开</a>
  </div>
</body>
</html>
