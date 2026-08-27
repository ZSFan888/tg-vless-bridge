<!DOCTYPE html>
<html lang="zh">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>MTProto 代理信息</title>
<style>
  body { font-family: -apple-system, BlinkMacSystemFont, sans-serif; background:#0f1115; color:#eee; display:flex; justify-content:center; padding:32px 16px; margin:0; }
  .card { background:#1a1d24; border-radius:14px; padding:24px; max-width:440px; width:100%; box-shadow:0 4px 20px rgba(0,0,0,.3); box-sizing:border-box; }
  h1 { font-size:20px; margin:0 0 18px; }
  h2 { font-size:15px; margin:26px 0 12px; color:#cbd1dc; }
  .row { margin:11px 0; word-break:break-all; display:flex; align-items:center; justify-content:space-between; gap:8px; }
  .value { flex:1; min-width:0; }
  .label { color:#8a8f98; font-size:11px; text-transform:uppercase; letter-spacing:.07em; margin-bottom:3px; }
  a.btn { display:block; width:100%; text-align:center; background:#2ea6ff; color:#fff; text-decoration:none; padding:12px; border-radius:8px; margin-top:13px; font-weight:600; box-sizing:border-box; }
  button.copy { background:#2a2e37; color:#eee; border:none; padding:7px 11px; border-radius:6px; font-size:12px; cursor:pointer; flex-shrink:0; }
  button.copy.copied { background:#2ea655; color:#fff; }
  img { display:block; margin:16px auto 0; border-radius:8px; background:#fff; }
  .stats { display:grid; grid-template-columns:1fr 1fr; gap:10px; }
  .stat { background:#232733; border-radius:9px; padding:12px; }
  .stat .num { font-size:20px; font-weight:650; margin-top:4px; }
  .stat .sub { color:#8a8f98; font-size:11px; margin-top:3px; }
  #status { font-size:12px; color:#8a8f98; margin-top:10px; text-align:right; }
</style>
</head>
<body>
  <main class="card">
    <h1>MTProto 代理连接信息</h1>
    <div class="row"><div class="value"><div class="label">Server</div>{{HOST}}</div></div>
    <div class="row"><div class="value"><div class="label">Port</div>{{PORT}}</div></div>
    <div class="row"><div class="value"><div class="label">Secret</div><span id="secret">{{SECRET}}</span></div><button class="copy" onclick="copyText('secret', this)">复制</button></div>
    <div class="row"><div class="value"><div class="label">连接链接</div><span id="link">{{LINK}}</span></div><button class="copy" onclick="copyText('link', this)">复制</button></div>
    <img src="{{QR}}" alt="QR code" width="220" height="220">
    <a class="btn" href="{{TGLINK}}">在 Telegram 中打开</a>

    <h2>实时状态</h2>
    <section class="stats">
      <div class="stat"><div class="label">当前客户端</div><div class="num" id="clients">—</div></div>
      <div class="stat"><div class="label">上游连接</div><div class="num" id="upstream">—</div></div>
      <div class="stat"><div class="label">累计上传</div><div class="num" id="inBytes">—</div><div class="sub" id="inRate"></div></div>
      <div class="stat"><div class="label">累计下载</div><div class="num" id="outBytes">—</div><div class="sub" id="outRate"></div></div>
    </section>
    <div id="status">正在读取统计…</div>
  </main>
<script>
function copyText(id, btn) {
  navigator.clipboard.writeText(document.getElementById(id).innerText).then(function() {
    var original = btn.innerText; btn.innerText = "已复制"; btn.classList.add("copied");
    setTimeout(function() { btn.innerText = original; btn.classList.remove("copied"); }, 1500);
  });
}
function fmt(bytes) {
  var units = ["B", "KB", "MB", "GB", "TB"], i = 0;
  while (bytes >= 1024 && i < units.length - 1) { bytes /= 1024; i++; }
  return (i ? bytes.toFixed(2) : Math.round(bytes)) + " " + units[i];
}
async function refresh() {
  try {
    var r = await fetch("/api/status", {cache:"no-store"}), d = await r.json();
    if (!d.ok) throw new Error(d.error || "无法读取统计");
    document.getElementById("clients").innerText = d.clients;
    document.getElementById("upstream").innerText = d.upstream;
    document.getElementById("inBytes").innerText = fmt(d.in_bytes);
    document.getElementById("outBytes").innerText = fmt(d.out_bytes);
    document.getElementById("inRate").innerText = "↑ " + fmt(d.in_rate) + "/s";
    document.getElementById("outRate").innerText = "↓ " + fmt(d.out_rate) + "/s";
    document.getElementById("status").innerText = "更新于 " + new Date(d.updated_at * 1000).toLocaleTimeString();
  } catch (e) { document.getElementById("status").innerText = "统计暂不可用"; }
}
refresh(); setInterval(refresh, 5000);
</script>
</body>
</html>
