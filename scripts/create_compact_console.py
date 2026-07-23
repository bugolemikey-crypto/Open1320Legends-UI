"""Create a size-constrained NIM Console source without the legacy panel flip animation."""
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "classes" / "Console.pre-fws-compaction.as"
OUTPUT = ROOT / "classes" / "Console.compact.as"
MARKER = "   static function changePanel(newPanelNum)"
REPLACEMENT = '''   static function changePanel(newPanelNum)
   {
      classes.Console.panelNum = newPanelNum;
      var pnl = classes.Console._BASE.panel;
      pnl.refreshMe();
   }
'''


def function_end(text: str, start: int) -> int:
    brace = text.index("{", start)
    depth = 0
    for index in range(brace, len(text)):
        char = text[index]
        if char == "{":
            depth += 1
        elif char == "}":
            depth -= 1
            if depth == 0:
                return index + 1
    raise ValueError("Unterminated changePanel function")


def main() -> None:
    text = SOURCE.read_text(encoding="utf-8")
    start = text.index(MARKER)
    end = function_end(text, start)
    OUTPUT.write_text(text[:start] + REPLACEMENT + text[end:], encoding="utf-8")
    print(f"Created {OUTPUT}")


if __name__ == "__main__":
    main()
