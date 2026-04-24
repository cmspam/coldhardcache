#!/usr/bin/env python3
"""
strip-private.py — remove import lines that reference a `private` path
segment from every .nix file under the given root directory.

Convention: private imports must be on their own line. The line's entire
non-whitespace content is the path literal, optionally followed by a
trailing `,` or `;`. Only lines matching this shape are stripped.

    imports = [
      ./hardware.nix
      ../../private/me.nix      # ← whole line stripped
      ./services.nix
    ];

Lines where a private path appears as the RHS of an assignment, inside a
string, in a comment, or anywhere else non-standalone are LEFT ALONE.
Those references are either:

  (a) inside a `builtins.pathExists`-style conditional that gracefully
      handles the file being absent — the value will be false when the
      stripped tree is built, and the fallback branch kicks in; or
  (b) text that happens to contain the word `private` (a docstring,
      a shell command in `interactiveShellInit`, etc.) — irrelevant to
      nix evaluation.

This keeps the stripper safe and predictable: it only removes things that
would actually break the build when the private/ directory is absent
(direct imports via `imports = [ … ]`).

Reports each stripped line to stderr. Exits 0 always — the stripper is
conservative by design; if something goes wrong post-strip, CI will fail
with a clear Nix evaluation error.
"""

import re
import sys
from pathlib import Path

# Match a line whose entire non-whitespace content is a Nix path literal
# containing `private` as a path segment (optionally with a trailing
# `,` or `;`). This is exactly the shape of an entry in an `imports = [ … ]`
# list, which is the only place stripping is needed.
STANDALONE_PRIVATE_PATH_RE = re.compile(
    r"""
    ^\s*                              # leading whitespace
    (?:\.{1,2}/)                      # must start with ./ or ../
    (?:[^/\s]+/)*                     # zero or more path segments
    private                           # the literal word 'private'
    (?:/[^/\s]+)*                     # optional sub-segments
    (?:\.nix)?                        # optional .nix suffix (imports of
                                       #   directories resolve via default.nix)
    \s*[,;]?\s*                       # optional trailing punctuation
    $
    """,
    re.VERBOSE,
)


def strip_file(path: Path) -> int:
    """Rewrite `path` with matching lines removed. Returns stripped count."""
    try:
        text = path.read_text()
    except (OSError, UnicodeDecodeError) as e:
        print(f"  skip {path}: {e}", file=sys.stderr)
        return 0

    in_lines = text.splitlines(keepends=True)
    out_lines: list[str] = []
    stripped = 0

    for line in in_lines:
        # Strip line-end for matching so trailing newline doesn't confuse `$`.
        content = line.rstrip("\n")
        if STANDALONE_PRIVATE_PATH_RE.match(content):
            stripped += 1
            print(f"  strip {path}: {content.rstrip()}", file=sys.stderr)
            continue
        out_lines.append(line)

    if stripped:
        path.write_text("".join(out_lines))

    return stripped


def main() -> int:
    if len(sys.argv) != 2:
        print("usage: strip-private.py <directory>", file=sys.stderr)
        return 2

    root = Path(sys.argv[1])
    if not root.is_dir():
        print(f"strip-private.py: {root} is not a directory", file=sys.stderr)
        return 2

    total = sum(strip_file(f) for f in sorted(root.rglob("*.nix")))
    print(
        f">>> strip-private: removed {total} private-import line(s)",
        file=sys.stderr,
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
