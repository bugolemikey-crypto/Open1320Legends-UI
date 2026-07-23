"""Interactive web-based SWF layout editor.

Launch with: python scripts/swf_layout_editor.py
Opens a browser with a visual editor showing the login background and
draggable control overlays. Adjust positions and scales, then rebuild
and deploy directly from the interface.
"""
from __future__ import annotations

import json
import subprocess
import sys
import threading
import webbrowser
from http.server import HTTPServer, BaseHTTPRequestHandler
from pathlib import Path
from urllib.parse import parse_qs, urlparse

ROOT = Path(__file__).resolve().parent.parent
LAYOUT_PATH = ROOT / "ui_layout.json"
PREPARED_DIR = ROOT / "assets" / "login" / "prepared"
BACKGROUND_IMAGE = PREPARED_DIR / "login_stage_800x600.png"
BUTTON_IMAGES = {
    "btnFBConnect": PREPARED_DIR / "btn_discord_174x29.png",
    "btnCreateAccount": PREPARED_DIR / "btn_create_172x29.png",
    "btnStart": PREPARED_DIR / "btn_login_172x29.png",
}

PORT = 8321


def load_layout() -> dict:
    return json.loads(LAYOUT_PATH.read_text(encoding="utf-8"))


def save_layout(data: dict) -> None:
    LAYOUT_PATH.write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8")


def run_build() -> tuple[bool, str]:
    try:
        result = subprocess.run(
            [sys.executable, str(ROOT / "scripts" / "build_deployable_login.py")],
            cwd=ROOT, capture_output=True, text=True, timeout=900
        )
        output = result.stdout + result.stderr
        return result.returncode == 0, output
    except Exception as e:
        return False, str(e)


def run_deploy() -> tuple[bool, str]:
    try:
        result = subprocess.run(
            [sys.executable, str(ROOT / "scripts" / "deploy_patches.py"), "--target", "main_client"],
            cwd=ROOT, capture_output=True, text=True, timeout=300
        )
        output = result.stdout + result.stderr
        return result.returncode == 0, output
    except Exception as e:
        return False, str(e)


def run_game() -> tuple[bool, str]:
    try:
        config = json.loads((ROOT / "config.json").read_text(encoding="utf-8"))
        game_root = Path(config["game_root"])
        exe = game_root / config["game_exe"]
        subprocess.Popen([str(exe)], cwd=str(game_root))
        return True, f"Launched {exe.name}"
    except Exception as e:
        return False, str(e)


HTML_PAGE = r"""<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>SWF Layout Editor - Open1320Legends</title>
<style>
* { margin: 0; padding: 0; box-sizing: border-box; }
body { background: #1a1a1a; color: #eee; font-family: 'Segoe UI', sans-serif; display: flex; height: 100vh; }
#sidebar { width: 320px; background: #222; padding: 16px; overflow-y: auto; border-right: 1px solid #444; }
#canvas-area { flex: 1; display: flex; align-items: center; justify-content: center; position: relative; }
#stage { position: relative; width: 800px; height: 600px; background: #000; overflow: hidden; cursor: crosshair; }
#stage img.bg { position: absolute; top: 0; left: 0; width: 100%; height: 100%; pointer-events: none; }
.control { position: absolute; border: 2px solid rgba(0, 200, 255, 0.7); background: rgba(0, 200, 255, 0.1); cursor: move; display: flex; align-items: center; justify-content: center; font-size: 11px; color: #fff; text-shadow: 0 0 3px #000; user-select: none; }
.control.selected { border-color: #ff0; background: rgba(255, 255, 0, 0.15); }
.control img { width: 100%; height: 100%; object-fit: contain; pointer-events: none; opacity: 0.9; }
h2 { color: #0cf; margin-bottom: 12px; font-size: 18px; }
h3 { color: #aaa; margin: 16px 0 8px; font-size: 13px; text-transform: uppercase; letter-spacing: 1px; }
.field { margin-bottom: 10px; }
.field label { display: block; font-size: 12px; color: #999; margin-bottom: 2px; }
.field input[type="number"] { width: 100%; background: #333; border: 1px solid #555; color: #eee; padding: 6px 8px; border-radius: 4px; font-size: 13px; }
.field input[type="range"] { width: 100%; }
.field .val { font-size: 11px; color: #888; text-align: right; }
select { width: 100%; background: #333; border: 1px solid #555; color: #eee; padding: 6px; border-radius: 4px; margin-bottom: 12px; }
button { width: 100%; padding: 10px; margin-top: 8px; border: none; border-radius: 4px; font-size: 14px; cursor: pointer; font-weight: bold; }
button.build { background: #0a7; color: #fff; }
button.deploy { background: #c40; color: #fff; }
button.launch { background: #36c; color: #fff; }
button.save { background: #555; color: #fff; }
button:hover { opacity: 0.85; }
#log { margin-top: 12px; background: #111; border: 1px solid #333; padding: 8px; font-family: monospace; font-size: 11px; max-height: 200px; overflow-y: auto; white-space: pre-wrap; color: #8f8; }
#coords { position: absolute; bottom: 8px; right: 8px; background: rgba(0,0,0,0.7); color: #0cf; padding: 4px 8px; border-radius: 4px; font-size: 12px; font-family: monospace; }
</style>
</head>
<body>
<div id="sidebar">
  <h2>SWF Layout Editor</h2>
  <label>Element:</label>
  <select id="elementSelect"></select>
  <div id="props"></div>
  <h3>Actions</h3>
  <button class="save" onclick="saveLayout()">Save Layout</button>
  <button class="build" onclick="buildSWF()">Build SWF</button>
  <button class="deploy" onclick="deploySWF()">Deploy to Game</button>
  <button class="launch" onclick="launchGame()">Launch Game</button>
  <button class="build" onclick="buildAndDeploy()" style="background:#f80;margin-top:16px">Build + Deploy + Launch</button>
  <div id="log"></div>
</div>
<div id="canvas-area">
  <div id="stage">
    <img class="bg" src="/api/background" alt="background">
    <div id="coords">x: 0, y: 0</div>
  </div>
</div>
<script>
let layout = null;
let controls = {};
let selectedName = null;
let dragging = null;
let dragOffset = {x: 0, y: 0};

async function init() {
  const resp = await fetch('/api/layout');
  layout = await resp.json();
  buildControls();
  buildSelect();
  selectElement(Object.keys(controls)[0]);
}

function buildControls() {
  const stage = document.getElementById('stage');
  document.querySelectorAll('.control').forEach(e => e.remove());
  controls = {};
  const sprite = layout.sprites[0];
  for (const [name, spec] of Object.entries(sprite.instances)) {
    const el = document.createElement('div');
    el.className = 'control';
    el.dataset.name = name;
    el.textContent = name;
    // Native sizes for buttons and fields
    const sizes = {
      btnFBConnect: {w: 174, h: 29},
      btnCreateAccount: {w: 172, h: 29},
      btnStart: {w: 172, h: 29},
      fldUsername: {w: 150, h: 22},
      fldPass: {w: 150, h: 22},
    };
    const native = sizes[name] || {w: 100, h: 25};
    const sx = spec.scaleX || 1;
    const sy = spec.scaleY || 1;
    el.style.left = spec.x + 'px';
    el.style.top = spec.y + 'px';
    el.style.width = Math.round(native.w * sx) + 'px';
    el.style.height = Math.round(native.h * sy) + 'px';
    // Add button image if available
    const imgMap = {
      btnFBConnect: '/api/button/btnFBConnect',
      btnCreateAccount: '/api/button/btnCreateAccount',
      btnStart: '/api/button/btnStart',
    };
    if (imgMap[name]) {
      const img = document.createElement('img');
      img.src = imgMap[name];
      el.textContent = '';
      el.appendChild(img);
    }
    el.addEventListener('mousedown', startDrag);
    el.addEventListener('click', (e) => { e.stopPropagation(); selectElement(name); });
    stage.appendChild(el);
    controls[name] = {el, spec, native};
  }
}

function buildSelect() {
  const sel = document.getElementById('elementSelect');
  sel.innerHTML = '';
  for (const name of Object.keys(controls)) {
    const opt = document.createElement('option');
    opt.value = name;
    opt.textContent = name;
    sel.appendChild(opt);
  }
  sel.onchange = () => selectElement(sel.value);
}

function selectElement(name) {
  selectedName = name;
  document.querySelectorAll('.control').forEach(el => el.classList.remove('selected'));
  if (controls[name]) controls[name].el.classList.add('selected');
  document.getElementById('elementSelect').value = name;
  renderProps();
}

function renderProps() {
  const container = document.getElementById('props');
  if (!selectedName || !controls[selectedName]) { container.innerHTML = ''; return; }
  const spec = controls[selectedName].spec;
  container.innerHTML = `
    <h3>${selectedName}</h3>
    <div class="field"><label>X</label><input type="number" id="px" value="${spec.x}" step="1" onchange="updateProp('x', this.value)"></div>
    <div class="field"><label>Y</label><input type="number" id="py" value="${spec.y}" step="1" onchange="updateProp('y', this.value)"></div>
    <div class="field"><label>Scale X</label><input type="range" id="psx" min="0.1" max="5" step="0.05" value="${spec.scaleX||1}" oninput="updateProp('scaleX', this.value); document.getElementById('sxval').textContent=this.value"><div class="val" id="sxval">${spec.scaleX||1}</div></div>
    <div class="field"><label>Scale Y</label><input type="range" id="psy" min="0.1" max="5" step="0.05" value="${spec.scaleY||1}" oninput="updateProp('scaleY', this.value); document.getElementById('syval').textContent=this.value"><div class="val" id="syval">${spec.scaleY||1}</div></div>
  `;
}

function updateProp(key, value) {
  if (!selectedName) return;
  const v = parseFloat(value);
  const sprite = layout.sprites[0];
  sprite.instances[selectedName][key] = v;
  controls[selectedName].spec[key] = v;
  repositionControl(selectedName);
  // Sync number inputs
  if (key === 'x') document.getElementById('px').value = v;
  if (key === 'y') document.getElementById('py').value = v;
}

function repositionControl(name) {
  const c = controls[name];
  const sx = c.spec.scaleX || 1;
  const sy = c.spec.scaleY || 1;
  c.el.style.left = c.spec.x + 'px';
  c.el.style.top = c.spec.y + 'px';
  c.el.style.width = Math.round(c.native.w * sx) + 'px';
  c.el.style.height = Math.round(c.native.h * sy) + 'px';
}

function startDrag(e) {
  const name = e.currentTarget.dataset.name;
  selectElement(name);
  dragging = name;
  const rect = e.currentTarget.getBoundingClientRect();
  dragOffset.x = e.clientX - rect.left;
  dragOffset.y = e.clientY - rect.top;
  e.preventDefault();
}

document.addEventListener('mousemove', (e) => {
  const stage = document.getElementById('stage');
  const stageRect = stage.getBoundingClientRect();
  const mx = Math.round(e.clientX - stageRect.left);
  const my = Math.round(e.clientY - stageRect.top);
  document.getElementById('coords').textContent = `x: ${mx}, y: ${my}`;
  if (!dragging) return;
  const x = Math.round(e.clientX - stageRect.left - dragOffset.x);
  const y = Math.round(e.clientY - stageRect.top - dragOffset.y);
  updateProp('x', x);
  updateProp('y', y);
  renderProps();
});

document.addEventListener('mouseup', () => { dragging = null; });

async function saveLayout() {
  log('Saving layout...');
  const resp = await fetch('/api/layout', {method: 'POST', headers: {'Content-Type': 'application/json'}, body: JSON.stringify(layout)});
  const data = await resp.json();
  log(data.message);
}

async function buildSWF() {
  log('Building SWF... (this takes ~30s)');
  await saveLayout();
  const resp = await fetch('/api/build', {method: 'POST'});
  const data = await resp.json();
  log(data.output);
  if (data.success) log('BUILD SUCCESS'); else log('BUILD FAILED');
}

async function deploySWF() {
  log('Deploying...');
  const resp = await fetch('/api/deploy', {method: 'POST'});
  const data = await resp.json();
  log(data.output);
  if (data.success) log('DEPLOY SUCCESS'); else log('DEPLOY FAILED');
}

async function launchGame() {
  log('Launching game...');
  const resp = await fetch('/api/launch', {method: 'POST'});
  const data = await resp.json();
  log(data.output);
}

async function buildAndDeploy() {
  await buildSWF();
  await deploySWF();
  await launchGame();
}

function log(msg) {
  const el = document.getElementById('log');
  el.textContent += msg + '\n';
  el.scrollTop = el.scrollHeight;
}

init();
</script>
</body>
</html>
"""


class EditorHandler(BaseHTTPRequestHandler):
    def log_message(self, format, *args):
        pass  # Suppress request logs

    def send_json(self, data: dict, status: int = 200):
        body = json.dumps(data).encode()
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def send_file(self, path: Path, content_type: str):
        if not path.exists():
            self.send_error(404)
            return
        data = path.read_bytes()
        self.send_response(200)
        self.send_header("Content-Type", content_type)
        self.send_header("Content-Length", str(len(data)))
        self.end_headers()
        self.wfile.write(data)

    def do_GET(self):
        parsed = urlparse(self.path)
        path = parsed.path

        if path == "/" or path == "/index.html":
            body = HTML_PAGE.encode()
            self.send_response(200)
            self.send_header("Content-Type", "text/html")
            self.send_header("Content-Length", str(len(body)))
            self.end_headers()
            self.wfile.write(body)

        elif path == "/api/layout":
            self.send_json(load_layout())

        elif path == "/api/background":
            self.send_file(BACKGROUND_IMAGE, "image/png")

        elif path.startswith("/api/button/"):
            name = path.split("/")[-1]
            if name in BUTTON_IMAGES:
                self.send_file(BUTTON_IMAGES[name], "image/png")
            else:
                self.send_error(404)

        else:
            self.send_error(404)

    def do_POST(self):
        parsed = urlparse(self.path)
        path = parsed.path

        if path == "/api/layout":
            length = int(self.headers.get("Content-Length", 0))
            body = self.rfile.read(length)
            data = json.loads(body)
            save_layout(data)
            self.send_json({"message": "Layout saved to ui_layout.json"})

        elif path == "/api/build":
            success, output = run_build()
            self.send_json({"success": success, "output": output})

        elif path == "/api/deploy":
            success, output = run_deploy()
            self.send_json({"success": success, "output": output})

        elif path == "/api/launch":
            success, output = run_game()
            self.send_json({"success": success, "output": output})

        else:
            self.send_error(404)


def main():
    # Ensure background exists
    if not BACKGROUND_IMAGE.exists():
        print("Generating background preview...")
        subprocess.run(
            [sys.executable, str(ROOT / "scripts" / "prepare_deployable_login_assets.py")],
            cwd=ROOT, timeout=120
        )

    server = HTTPServer(("127.0.0.1", PORT), EditorHandler)
    url = f"http://127.0.0.1:{PORT}"
    print(f"SWF Layout Editor running at {url}")
    print("Press Ctrl+C to stop.\n")

    # Open browser after a short delay
    threading.Timer(0.5, lambda: webbrowser.open(url)).start()

    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\nEditor stopped.")
        server.shutdown()


if __name__ == "__main__":
    main()
