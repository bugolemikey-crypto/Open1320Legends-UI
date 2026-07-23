"""Same-size binary string patches for Discord login in main.swf."""
from __future__ import annotations

import argparse
import shutil
from pathlib import Path

from swf_utils import ROOT, load_config


def pad(text: str, size: int) -> bytes:
    encoded = text.encode("utf-8")
    if len(encoded) > size:
        raise ValueError(f"Replacement too long ({len(encoded)} > {size}): {text!r}")
    if len(encoded) < size:
        encoded += b" " * (size - len(encoded))
    return encoded


def patch_bytes(data: bytearray, old: bytes, new: bytes) -> None:
    if len(old) != len(new):
        raise ValueError(f"Length mismatch for {old!r}")
    count = data.count(old)
    if count == 0:
        if data.count(new):
            print(f"Already patched: {old[:40]!r}...")
            return
        raise RuntimeError(f"String not found: {old!r}")
    data[:] = bytes(data).replace(old, new)
    print(f"Patched {count}x {old[:40]!r}...")


def build_replacements() -> list[tuple[bytes, bytes]]:
    help_old = (
        "Click this button to sign in with your Facebook account.  You can link an existing "
        "1320 Legends account or create a brand new one.  You\u2019ll be automatically logged in "
        "and you\u2019ll be able to see your Facebook friends who are playing 1320 Legends and "
        "update them with your game achievements"
    )
    help_new = (
        "Click this button to sign in with your Discord account. You can link an existing 1320 "
        "Legends account or create a brand new one. After you authorize in your browser you will "
        "be logged in automatically. Use username/password login if you prefer not to use Discord."
    )
    help_old_b = help_old.encode("utf-8")
    help_new_b = pad(help_new, len(help_old_b))

    account_old = (
        "No matching Nitto account! Login and connect accounts or create a new one"
    )
    account_new = (
        "No matching Legends account! Log in and link accounts or create a new one"
    )
    account_old_b = account_old.encode("utf-8")
    account_new_b = pad(account_new, len(account_old_b))

    return [
        (b"Facebook Connect", pad("Discord Connect", 16)),
        (b"Facebook Error", pad("Discord Error", 14)),
        (b"facebook, please try again", pad("discord, please try again", 26)),
        (help_old_b, help_new_b),
        (account_old_b, account_new_b),
        (
            b"Error disconnecting account from Facebook. Please try again later.",
            pad("Error disconnecting account from Discord. Please try again later.", 66),
        ),
        (b"Invite Friends", pad("", 14)),
        (b"tog_fbInvite", b"tog_noInvite"),
    ]


def patch_main_swf(src: Path, dest: Path) -> None:
    dest.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(src, dest)
    data = bytearray(dest.read_bytes())
    original_size = len(data)

    for old, new in build_replacements():
        patch_bytes(data, old, new)

    if len(data) != original_size:
        raise RuntimeError(f"SWF size changed: {original_size} -> {len(data)}")

    dest.write_bytes(data)
    print(f"Wrote {dest} ({len(data):,} bytes, size preserved)")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--source",
        type=Path,
        default=ROOT / "source" / "main.swf",
    )
    parser.add_argument(
        "--output",
        type=Path,
        default=ROOT / "patches" / "main_client" / "main.swf",
    )
    args = parser.parse_args()
    if not args.source.exists():
        raise SystemExit(f"Source SWF not found: {args.source}")
    patch_main_swf(args.source, args.output)


if __name__ == "__main__":
    main()
