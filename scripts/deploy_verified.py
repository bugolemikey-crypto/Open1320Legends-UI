"""Build, prove the payload is ours, then deploy. Use this instead of calling
build_polish_patch.py and deploy_patches.py separately.

Why this exists
---------------
`patches/` in a worktree is a **junction** into the main checkout, so every
checkout and every parallel session writes the same
`patches/main_client/main.polish.swf` and `main.swf`. A build is therefore not
still yours by the time you deploy.

Two weaker checks both failed in practice:

* Hashing the exe's embedded slot afterwards proves the bytes landed, not that
  they were the right bytes. It happily confirmed an unrelated old client.
* Comparing `main.polish.swf` against `main.swf` proves nothing either, because
  a foreign build overwrites **both together** - they matched each other
  perfectly while holding another branch's work (staggered wheels, not pearl).

The only check that works is a **content** assertion: decompile the payload and
look for the code that is supposed to be in it. That is what MARKERS are.

Add a marker whenever you add a feature here, so a foreign build can never be
mistaken for yours.
"""
from __future__ import annotations

import argparse
import subprocess
import sys
import tempfile
from pathlib import Path

from swf_utils import ROOT, resolve_ffdec_path

DEPLOY_SOURCE = ROOT / "patches" / "main_client" / "main.swf"

# path-inside-export -> substrings that must be present.
MARKERS = {
    "scripts/__Packages/classes/CarConstruction.as": [
        "normClr",          # shared base-colour normalisation
        "candyFilter",      # candy hue derivation
        "pearlFilter",      # pearl hue travel
        "setPartFlake",     # metallic flake
        "finishMap",        # per-car finish
        "finishStore",      # local persistence (server rejects 8-char cc)
        "setCarFinish",     # persisting setter
    ],
    "scripts/__Packages/classes/CarSpecs.as": [
        "acctCarID",        # carries the per-car key
    ],
    "scripts/DefineSprite_3719/frame_1/DoAction.as": [
        "Gloss finish", "Matte finish", "Satin finish",
        "Candy finish", "Flake finish", "Pearl finish",
    ],
}


def run(cmd: list[str]) -> None:
    subprocess.run(cmd, check=True)


def content_gate(ffdec: str, payload: Path) -> None:
    """Decompile `payload` and assert every marker is present."""
    with tempfile.TemporaryDirectory(prefix="gate-") as tmp:
        subprocess.run([ffdec, "-export", "script", tmp, str(payload)],
                       check=True, stdout=subprocess.DEVNULL,
                       stderr=subprocess.DEVNULL)
        missing: list[str] = []
        for rel, pats in MARKERS.items():
            path = Path(tmp) / rel
            if not path.exists():
                missing.append(f"{rel} (file absent from payload)")
                continue
            text = path.read_text(encoding="utf-8", errors="replace")
            for pat in pats:
                if pat not in text:
                    missing.append(f"{rel}: {pat}")
        if missing:
            raise RuntimeError(
                "payload is not this worktree's build - missing:\n  "
                + "\n  ".join(missing)
                + "\n\nAnother checkout almost certainly rebuilt through the "
                  "patches/ junction. Re-run this script; if it keeps failing, "
                  "find the other build and stop it first."
            )
    # flush: subprocesses write straight to the console, so unflushed prints here
    # surface after them and make the log read as though the gate ran last.
    print(f"Content gate passed ({sum(len(v) for v in MARKERS.values())} markers)",
          flush=True)


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--skip-build", action="store_true",
                    help="Gate and deploy the payload already on disk")
    args = ap.parse_args()

    ffdec = resolve_ffdec_path()
    if not args.skip_build:
        run([sys.executable, str(ROOT / "scripts" / "build_polish_patch.py")])

    content_gate(ffdec, DEPLOY_SOURCE)
    before = DEPLOY_SOURCE.read_bytes()

    run([sys.executable, str(ROOT / "scripts" / "deploy_patches.py"),
         "--target", "main_client"])

    # The gate ran against these exact bytes, so matching them means the verified
    # payload is what landed - and that nothing swapped the file mid-deploy.
    if DEPLOY_SOURCE.read_bytes() != before:
        raise RuntimeError(
            "the deploy source changed while deploying - a concurrent build "
            "clobbered it. Re-run this script."
        )
    print("Deployed the verified payload", flush=True)


if __name__ == "__main__":
    try:
        main()
    except (OSError, RuntimeError, subprocess.SubprocessError) as exc:
        raise SystemExit(f"ERROR: {exc}")
