<!DOCTYPE html>
<html lang="zh">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>MTProto 代理信息</title>
<style>
  body { font-family: -apple-system, sans-serif; background:#0f1115; color:#eee; display:flex; flex-direction:column; align-items:center; padding:40px 16px; margin:0; }
  .card { background:#1a1d24; border-radius:12px; padding:24px 32px; max-width:420px; width:100%; box-shadow:0 4px 20px rgba(0,0,0,.3); box-sizing:border-box; }
  h1 { font-size:18px; margin-top:0; }
  .row { margin:10px 0; word-break:break-all; display:flex; align-items:center; justify-content:space-between; gap:8px; }
  .row .val { flex:1; }
  .label { color:#8a8f98; font-size:12px; text-transform:uppercase; letter-spacing:.05em; }
  a.btn, button.btn { display:block; width:100%; text-align:center; background:#2ea6ff; color:#fff; text-decoration:none; padding:12px; border-radius:8px; margin-top:12px; font-weight:600; border:none; font-size:15px; cursor:pointer; box-sizing:border-box; }
  button.copy { background:#2a2e37; color:#eee; border:none; padding:6px 12px; border-radius:6px; font-size:12px; cursor:pointer; flex-shrink:0; }
  button.copy.copied { background:#2ea655; color:#fff; }
  img { display:block; margin:16px auto 0; border-radius:8px; }
</style>
</head>
<body>
  <div class="card">
    <h1>MTProto 代理连接信息</h1>
    <div class="row"><div><div class="label">Server</div><span class="val">{{HOST}}</span></div></div>
    <div class="row"><div><div class="label">Port</div><span class="val">{{PORT}}</span></div></div>
    <div class="row">
      <div style="flex:1"><div class="label">Secret</div><span class="val" id="secret">{{SECRET}}</span></div>
      <button class="copy" onclick="copyText('secret', this)">复制</button>
    </div>
    <div class="row">
      <div style="flex:1"><div class="label">连接链接</div><span class="val" id="link">{{LINK}}</span></div>
      <button class="copy" onclick="copyText('link', this)">复制</button>
    </div>
    <img src="{{QR}}" alt="QR code" width="220" height="220">
    <a class="btn" href="{{TGLINK}}">在 Telegram 中打开</a>
  </div>
<script>
function copyText(id, btn) {
  var text = document.getElementById(id).innerText;
  navigator.clipboard.writeText(text).then(function() {
    var original = btn.innerText;
    btn.innerText = "已复制";
    btn.classList.add("copied");
    setTimeout(function() {
      btn.innerText = original;
      btn.classList.remove("copied");
    }, 1500);
  });
}
</script>
</body>
</html>
