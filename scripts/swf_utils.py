"""FFDec helpers for Open1320Legends UI modding."""
from __future__ import annotations

import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CONFIG_PATH = ROOT / "config.json"

FFDEC_DEFAULT_PATHS = [
    r"C:\Program Files (x86)\FFDec\ffdec-cli.exe",
    r"C:\Program Files\FFDec\ffdec-cli.exe",
    r"C:\Program Files (x86)\FFDec\ffdec.bat",
    r"C:\Program Files\FFDec\ffdec.bat",
]

_NO_WINDOW = 0x08000000


def load_config() -> dict:
    with CONFIG_PATH.open(encoding="utf-8") as fh:
        return json.load(fh)


def resolve_ffdec_path(config: dict | None = None) -> str:
    config = config or load_config()
    configured = config.get("ffdec_path")
    if configured and Path(configured).exists():
        return configured
    for candidate in FFDEC_DEFAULT_PATHS:
        if Path(candidate).exists():
            return candidate
    raise FileNotFoundError(
        "FFDec not found. Install FFDec or set ffdec_path in config.json."
    )


def game_root(config: dict | None = None) -> Path:
    config = config or load_config()
    return Path(config["game_root"])


def run_ffdec(*args: str, timeout: int = 120) -> subprocess.CompletedProcess:
    ffdec = resolve_ffdec_path()
    cmd = [ffdec, *args]
    result = subprocess.run(
        cmd,
        capture_output=True,
        text=True,
        timeout=timeout,
        creationflags=_NO_WINDOW,
    )
    result.ok = result.returncode in (0, 255)  # noqa: B010
    return result


def export_images(swf_path: Path, out_dir: Path, timeout: int = 120) -> None:
    out_dir.mkdir(parents=True, exist_ok=True)
    result = run_ffdec("-export", "image", str(out_dir), str(swf_path), timeout=timeout)
    if not result.ok:
        raise RuntimeError(result.stderr or result.stdout or "FFDec image export failed")


def export_scripts(swf_path: Path, out_dir: Path, timeout: int = 300) -> None:
    out_dir.mkdir(parents=True, exist_ok=True)
    result = run_ffdec("-export", "script", str(out_dir), str(swf_path), timeout=timeout)
    if not result.ok:
        raise RuntimeError(result.stderr or result.stdout or "FFDec script export failed")


def replace_image(
    src_swf: Path,
    out_swf: Path,
    char_id: int,
    image_path: Path,
    timeout: int = 120,
) -> None:
    result = run_ffdec(
        "-replace",
        str(src_swf),
        str(out_swf),
        str(char_id),
        str(image_path),
        timeout=timeout,
    )
    if not result.ok:
        raise RuntimeError(result.stderr or result.stdout or "FFDec replace failed")


def replace_script(
    src_swf: Path,
    out_swf: Path,
    script_name: str,
    script_path: Path,
    timeout: int = 120,
) -> None:
    result = run_ffdec(
        "-replace",
        str(src_swf),
        str(out_swf),
        script_name,
        str(script_path),
        timeout=timeout,
    )
    if not result.ok:
        raise RuntimeError(result.stderr or result.stdout or f"FFDec replace failed for {script_name}")


def import_scripts(swf_path: Path, scripts_dir: Path, timeout: int = 300) -> None:
    result = run_ffdec(
        "-importScript",
        str(swf_path),
        str(swf_path),
        str(scripts_dir),
        timeout=timeout,
    )
    if not result.ok:
        raise RuntimeError(result.stderr or result.stdout or "FFDec script import failed")
