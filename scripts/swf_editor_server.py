"""Comprehensive SWF Editor - Python backend wrapping FFDec CLI.

Exposes all FFDec capabilities via a local HTTP API:
- Tag/character browser
- Image export/replace
- Script export/edit/replace
- Text export/edit
- Shape/sprite/font export
- SWF header viewing/editing
- XML round-trip (swf2xml/xml2swf)
- Compress/decompress
- Remove characters
- Full build/deploy/launch pipeline

Launch: python scripts/swf_editor_server.py [--port 8322] [--swf path/to/file.swf]
"""
from __future__ import annotations

import argparse
import base64
import json
import os
import shutil
import subprocess
import sys
import tempfile
import threading
import webbrowser
from http.server import HTTPServer, BaseHTTPRequestHandler
from pathlib import Path
from urllib.parse import parse_qs, urlparse, unquote

ROOT = Path(__file__).resolve().parent.parent
CONFIG_PATH = ROOT / "config.json"
LAYOUT_PATH = ROOT / "ui_layout.json"

# Will be set by CLI args or defaults
FFDEC = None
WORKING_SWF = None
EXPORT_CACHE = None


def load_config() -> dict:
    if CONFIG_PATH.exists():
        return json.loads(CONFIG_PATH.read_text(encoding="utf-8"))
    return {}


def ffdec_path() -> str:
    global FFDEC
    if FFDEC:
        return FFDEC
    config = load_config()
    FFDEC = config.get("ffdec_path", r"C:\Program Files (x86)\FFDec\ffdec-cli.exe")
    return FFDEC


def run_ffdec(*args: str, timeout: int = 600) -> subprocess.CompletedProcess:
    cmd = [ffdec_path(), *args]
    return subprocess.run(
        cmd, capture_output=True, text=True, timeout=timeout,
        creationflags=0x08000000 if sys.platform == "win32" else 0
    )


def ensure_export_cache():
    """Export all resources from the working SWF into a temp cache dir."""
    global EXPORT_CACHE
    if EXPORT_CACHE and Path(EXPORT_CACHE).exists():
        return EXPORT_CACHE
    EXPORT_CACHE = tempfile.mkdtemp(prefix="swf-editor-cache-")
    return EXPORT_CACHE


# ─── API Handlers ────────────────────────────────────────────────────────────

def api_info() -> dict:
    """Return basic info about the loaded SWF."""
    swf = Path(WORKING_SWF)
    result = run_ffdec("-header", str(swf))
    header_info = result.stdout.strip() if result.returncode == 0 else result.stderr
    return {
        "swf_path": str(swf),
        "swf_name": swf.name,
        "swf_size": swf.stat().st_size,
        "header": header_info,
        "ffdec_version": "26.2.1",
    }


def api_dump_tags() -> dict:
    """List all SWF tags."""
    result = run_ffdec("-dumpSWF", str(WORKING_SWF))
    if result.returncode != 0:
        return {"error": result.stderr, "tags": []}
    lines = result.stdout.strip().split("\n")
    tags = []
    for line in lines:
        line = line.strip()
        if line and not line.startswith("JPEXS") and not line.startswith("---"):
            tags.append(line)
    return {"tags": tags, "count": len(tags)}


def api_dump_scripts() -> dict:
    """List all AS2 scripts."""
    result = run_ffdec("-dumpAS2", "-exportNames", str(WORKING_SWF))
    if result.returncode != 0:
        return {"error": result.stderr, "scripts": []}
    lines = [l.strip() for l in result.stdout.strip().split("\n")
             if l.strip() and not l.strip().startswith("JPEXS") and not l.strip().startswith("---")]
    return {"scripts": lines, "count": len(lines)}


def api_export(item_type: str, format_str: str = None, char_id: str = None) -> dict:
    """Export items of a given type to the cache directory."""
    cache = ensure_export_cache()
    out_dir = os.path.join(cache, item_type)
    if os.path.exists(out_dir):
        shutil.rmtree(out_dir)
    os.makedirs(out_dir, exist_ok=True)

    args = []
    if format_str:
        args.extend(["-format", format_str])
    if char_id:
        args.extend(["-selectid", char_id])
    args.extend(["-export", item_type, out_dir, str(WORKING_SWF)])

    result = run_ffdec(*args, timeout=900)
    if result.returncode not in (0, 255):
        return {"error": result.stderr or result.stdout, "files": []}

    # Collect exported files
    files = []
    for root_dir, dirs, fnames in os.walk(out_dir):
        for fname in fnames:
            full = os.path.join(root_dir, fname)
            rel = os.path.relpath(full, out_dir)
            files.append({"path": rel, "size": os.path.getsize(full), "full_path": full})

    return {"files": files, "count": len(files), "output_dir": out_dir}


def api_get_file(file_path: str) -> tuple[bytes, str]:
    """Read a file from the export cache and return its bytes + content type."""
    path = Path(file_path)
    if not path.exists():
        return b"", "text/plain"

    ext = path.suffix.lower()
    content_types = {
        ".png": "image/png", ".jpg": "image/jpeg", ".jpeg": "image/jpeg",
        ".gif": "image/gif", ".svg": "image/svg+xml", ".webp": "image/webp",
        ".as": "text/plain", ".txt": "text/plain", ".json": "application/json",
        ".xml": "text/xml", ".ttf": "font/ttf", ".woff": "font/woff",
        ".mp3": "audio/mpeg", ".wav": "audio/wav",
    }
    ct = content_types.get(ext, "application/octet-stream")
    return path.read_bytes(), ct


def api_replace_image(char_id: str, image_data: bytes, format_hint: str = "jpeg3") -> dict:
    """Replace an image character with uploaded data."""
    swf = Path(WORKING_SWF)
    with tempfile.NamedTemporaryFile(suffix=".png", delete=False) as tmp:
        tmp.write(image_data)
        tmp_path = tmp.name

    out_swf = str(swf) + ".tmp"
    try:
        result = run_ffdec("-replace", str(swf), out_swf, char_id, tmp_path, format_hint)
        if result.returncode in (0, 255):
            shutil.move(out_swf, str(swf))
            return {"success": True, "message": f"Replaced character {char_id}"}
        else:
            return {"success": False, "message": result.stderr or result.stdout}
    finally:
        os.unlink(tmp_path)
        if os.path.exists(out_swf):
            os.unlink(out_swf)


def api_replace_script(script_name: str, script_content: str) -> dict:
    """Replace an AS2 script by name."""
    swf = Path(WORKING_SWF)
    with tempfile.NamedTemporaryFile(suffix=".as", mode="w", encoding="utf-8", delete=False) as tmp:
        tmp.write(script_content)
        tmp_path = tmp.name

    out_swf = str(swf) + ".tmp"
    try:
        result = run_ffdec("-replace", str(swf), out_swf, script_name, tmp_path)
        if result.returncode in (0, 255):
            shutil.move(out_swf, str(swf))
            return {"success": True, "message": f"Replaced script {script_name}"}
        else:
            return {"success": False, "message": result.stderr or result.stdout}
    finally:
        os.unlink(tmp_path)
        if os.path.exists(out_swf):
            os.unlink(out_swf)


def api_remove_character(char_id: str, with_deps: bool = False) -> dict:
    """Remove a character tag from the SWF."""
    swf = Path(WORKING_SWF)
    out_swf = str(swf) + ".tmp"
    cmd = "-removeCharacterWithDependencies" if with_deps else "-removeCharacter"
    result = run_ffdec(cmd, str(swf), out_swf, char_id)
    if result.returncode in (0, 255):
        shutil.move(out_swf, str(swf))
        return {"success": True, "message": f"Removed character {char_id}"}
    else:
        if os.path.exists(out_swf):
            os.unlink(out_swf)
        return {"success": False, "message": result.stderr or result.stdout}


def api_header_get() -> dict:
    """Get SWF header info."""
    result = run_ffdec("-header", str(WORKING_SWF))
    return {"header": result.stdout.strip(), "success": result.returncode == 0}


def api_header_set(settings: dict) -> dict:
    """Set SWF header values."""
    swf = Path(WORKING_SWF)
    out_swf = str(swf) + ".tmp"
    args = ["-header"]
    for key, value in settings.items():
        args.extend(["-set", key, str(value)])
    args.extend([str(swf), out_swf])
    result = run_ffdec(*args)
    if result.returncode in (0, 255):
        shutil.move(out_swf, str(swf))
        return {"success": True, "message": "Header updated"}
    else:
        if os.path.exists(out_swf):
            os.unlink(out_swf)
        return {"success": False, "message": result.stderr or result.stdout}


def api_swf2xml() -> dict:
    """Convert SWF to XML for viewing/editing."""
    cache = ensure_export_cache()
    xml_path = os.path.join(cache, "main.xml")
    result = run_ffdec("-swf2xml", str(WORKING_SWF), xml_path, timeout=900)
    if result.returncode in (0, 255) and os.path.exists(xml_path):
        content = Path(xml_path).read_text(encoding="utf-8", errors="replace")
        return {"success": True, "xml_path": xml_path, "size": len(content),
                "preview": content[:5000] if len(content) > 5000 else content}
    return {"success": False, "message": result.stderr or result.stdout}


def api_xml2swf(xml_path: str) -> dict:
    """Convert XML back to SWF."""
    swf = Path(WORKING_SWF)
    out_swf = str(swf) + ".tmp"
    result = run_ffdec("-xml2swf", xml_path, out_swf, timeout=900)
    if result.returncode in (0, 255):
        shutil.move(out_swf, str(swf))
        return {"success": True, "message": "SWF rebuilt from XML"}
    else:
        if os.path.exists(out_swf):
            os.unlink(out_swf)
        return {"success": False, "message": result.stderr or result.stdout}


def api_compress(method: str = "zlib") -> dict:
    """Compress the working SWF."""
    swf = Path(WORKING_SWF)
    out_swf = str(swf) + ".tmp"
    result = run_ffdec("-compress", method, str(swf), out_swf)
    if result.returncode in (0, 255):
        shutil.move(out_swf, str(swf))
        return {"success": True, "message": f"Compressed with {method}"}
    else:
        if os.path.exists(out_swf):
            os.unlink(out_swf)
        return {"success": False, "message": result.stderr or result.stdout}


def api_decompress() -> dict:
    """Decompress the working SWF."""
    swf = Path(WORKING_SWF)
    out_swf = str(swf) + ".tmp"
    result = run_ffdec("-decompress", str(swf), out_swf)
    if result.returncode in (0, 255):
        shutil.move(out_swf, str(swf))
        return {"success": True, "message": "Decompressed"}
    else:
        if os.path.exists(out_swf):
            os.unlink(out_swf)
        return {"success": False, "message": result.stderr or result.stdout}


def api_build_login() -> dict:
    """Run the full login build pipeline."""
    result = subprocess.run(
        [sys.executable, str(ROOT / "scripts" / "build_deployable_login.py")],
        cwd=ROOT, capture_output=True, text=True, timeout=900
    )
    return {"success": result.returncode == 0, "output": result.stdout + result.stderr}


def api_deploy() -> dict:
    """Deploy patches to game."""
    result = subprocess.run(
        [sys.executable, str(ROOT / "scripts" / "deploy_patches.py"), "--target", "main_client"],
        cwd=ROOT, capture_output=True, text=True, timeout=300
    )
    return {"success": result.returncode == 0, "output": result.stdout + result.stderr}


def api_launch_game() -> dict:
    """Launch the game executable."""
    try:
        config = load_config()
        game_root = Path(config["game_root"])
        exe = game_root / config["game_exe"]
        subprocess.Popen([str(exe)], cwd=str(game_root))
        return {"success": True, "output": f"Launched {exe.name}"}
    except Exception as e:
        return {"success": False, "output": str(e)}


def api_layout_get() -> dict:
    """Get the current ui_layout.json."""
    if LAYOUT_PATH.exists():
        return json.loads(LAYOUT_PATH.read_text(encoding="utf-8"))
    return {}


def api_layout_set(data: dict) -> dict:
    """Save ui_layout.json."""
    LAYOUT_PATH.write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8")
    return {"success": True, "message": "Layout saved"}


def api_list_swfs() -> dict:
    """List available SWF files in the project."""
    swfs = []
    for d in [ROOT / "source", ROOT / "patches" / "main_client",
              ROOT / "patches" / "login_form", ROOT / "patches" / "loading_screen"]:
        if d.exists():
            for f in d.glob("*.swf"):
                swfs.append({"path": str(f), "name": f.name, "size": f.stat().st_size,
                             "dir": d.name})
    # Also check game cache
    config = load_config()
    cache = Path(config.get("game_root", "")) / "cache" / "misc"
    if cache.exists():
        for f in cache.glob("*.swf"):
            swfs.append({"path": str(f), "name": f.name, "size": f.stat().st_size,
                         "dir": "game/cache"})
    return {"swfs": swfs}


def api_open_swf(path: str) -> dict:
    """Switch the working SWF to a different file."""
    global WORKING_SWF, EXPORT_CACHE
    p = Path(path)
    if not p.exists():
        return {"success": False, "message": f"File not found: {path}"}
    WORKING_SWF = str(p)
    # Clear export cache
    if EXPORT_CACHE and os.path.exists(EXPORT_CACHE):
        shutil.rmtree(EXPORT_CACHE, ignore_errors=True)
    EXPORT_CACHE = None
    return {"success": True, "message": f"Opened {p.name}", "info": api_info()}


# ─── HTTP Server ─────────────────────────────────────────────────────────────

class EditorHandler(BaseHTTPRequestHandler):
    def log_message(self, format, *args):
        pass

    def send_json(self, data, status=200):
        body = json.dumps(data, default=str).encode()
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Access-Control-Allow-Origin", "*")
        self.end_headers()
        self.wfile.write(body)

    def send_bytes(self, data: bytes, content_type: str, status=200):
        self.send_response(status)
        self.send_header("Content-Type", content_type)
        self.send_header("Content-Length", str(len(data)))
        self.send_header("Access-Control-Allow-Origin", "*")
        self.end_headers()
        self.wfile.write(data)

    def read_body(self) -> bytes:
        length = int(self.headers.get("Content-Length", 0))
        return self.rfile.read(length)

    def do_OPTIONS(self):
        self.send_response(200)
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type")
        self.end_headers()

    def do_GET(self):
        parsed = urlparse(self.path)
        path = parsed.path
        params = parse_qs(parsed.query)

        if path == "/":
            self.send_bytes(get_frontend_html().encode(), "text/html")
        elif path == "/api/info":
            self.send_json(api_info())
        elif path == "/api/tags":
            self.send_json(api_dump_tags())
        elif path == "/api/scripts":
            self.send_json(api_dump_scripts())
        elif path == "/api/export":
            item_type = params.get("type", ["image"])[0]
            fmt = params.get("format", [None])[0]
            char_id = params.get("id", [None])[0]
            self.send_json(api_export(item_type, fmt, char_id))
        elif path == "/api/file":
            file_path = params.get("path", [""])[0]
            data, ct = api_get_file(unquote(file_path))
            if data:
                self.send_bytes(data, ct)
            else:
                self.send_json({"error": "File not found"}, 404)
        elif path == "/api/background":
            bg = ROOT / "assets" / "login" / "prepared" / "login_stage_800x600.png"
            if bg.exists():
                self.send_bytes(bg.read_bytes(), "image/png")
            else:
                self.send_json({"error": "Background not found"}, 404)
        elif path.startswith("/api/button/"):
            name = path.split("/")[-1]
            button_map = {
                "btnFBConnect": ROOT / "assets" / "login" / "prepared" / "btn_discord_174x29.png",
                "btnCreateAccount": ROOT / "assets" / "login" / "prepared" / "btn_create_172x29.png",
                "btnStart": ROOT / "assets" / "login" / "prepared" / "btn_login_172x29.png",
            }
            btn_path = button_map.get(name)
            if btn_path and btn_path.exists():
                self.send_bytes(btn_path.read_bytes(), "image/png")
            else:
                self.send_json({"error": "Button not found"}, 404)
        elif path == "/api/header":
            self.send_json(api_header_get())
        elif path == "/api/swf2xml":
            self.send_json(api_swf2xml())
        elif path == "/api/layout":
            self.send_json(api_layout_get())
        elif path == "/api/swfs":
            self.send_json(api_list_swfs())
        else:
            self.send_json({"error": "Not found"}, 404)

    def do_POST(self):
        parsed = urlparse(self.path)
        path = parsed.path
        params = parse_qs(parsed.query)

        if path == "/api/replace/image":
            char_id = params.get("id", [""])[0]
            fmt = params.get("format", ["jpeg3"])[0]
            data = self.read_body()
            self.send_json(api_replace_image(char_id, data, fmt))
        elif path == "/api/replace/script":
            body = json.loads(self.read_body())
            self.send_json(api_replace_script(body["name"], body["content"]))
        elif path == "/api/remove":
            body = json.loads(self.read_body())
            self.send_json(api_remove_character(
                body["id"], body.get("with_deps", False)))
        elif path == "/api/header":
            body = json.loads(self.read_body())
            self.send_json(api_header_set(body))
        elif path == "/api/xml2swf":
            body = json.loads(self.read_body())
            self.send_json(api_xml2swf(body["xml_path"]))
        elif path == "/api/compress":
            body = json.loads(self.read_body()) if int(self.headers.get("Content-Length", 0)) > 0 else {}
            self.send_json(api_compress(body.get("method", "zlib")))
        elif path == "/api/decompress":
            self.send_json(api_decompress())
        elif path == "/api/build":
            self.send_json(api_build_login())
        elif path == "/api/deploy":
            self.send_json(api_deploy())
        elif path == "/api/launch":
            self.send_json(api_launch_game())
        elif path == "/api/layout":
            body = json.loads(self.read_body())
            self.send_json(api_layout_set(body))
        elif path == "/api/open":
            body = json.loads(self.read_body())
            self.send_json(api_open_swf(body["path"]))
        else:
            self.send_json({"error": "Not found"}, 404)


def get_frontend_html() -> str:
    """Return the full editor frontend HTML."""
    frontend_path = ROOT / "scripts" / "swf_editor_frontend.html"
    if frontend_path.exists():
        return frontend_path.read_text(encoding="utf-8")
    return "<html><body><h1>Frontend not found</h1><p>Place swf_editor_frontend.html in scripts/</p></body></html>"


def main():
    global WORKING_SWF

    parser = argparse.ArgumentParser(description="SWF Editor Server")
    parser.add_argument("--port", type=int, default=8322)
    parser.add_argument("--swf", type=str, default=str(ROOT / "patches" / "main_client" / "main.swf"))
    parser.add_argument("--no-browser", action="store_true")
    args = parser.parse_args()

    WORKING_SWF = args.swf
    if not Path(WORKING_SWF).exists():
        # Fall back to source
        WORKING_SWF = str(ROOT / "source" / "main.swf")

    print(f"SWF Editor Server v1.0")
    print(f"FFDec: {ffdec_path()}")
    print(f"Working SWF: {WORKING_SWF}")
    print(f"Project root: {ROOT}")
    print()

    server = HTTPServer(("127.0.0.1", args.port), EditorHandler)
    url = f"http://127.0.0.1:{args.port}"
    print(f"Editor running at {url}")
    print("Press Ctrl+C to stop.\n")

    if not args.no_browser:
        threading.Timer(0.5, lambda: webbrowser.open(url)).start()

    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\nServer stopped.")
        server.shutdown()


if __name__ == "__main__":
    main()
