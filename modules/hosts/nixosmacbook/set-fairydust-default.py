"""Select the newest installed entry for the configured Fairydust system."""

import os
from pathlib import Path
import re
import shlex
import sys


loader_dir = Path(sys.argv[1])
target_init = f"init={sys.argv[2]}"
matches = []
for entry in (loader_dir / "entries").glob("*.conf"):
    fields = dict(
        line.split(maxsplit=1)
        for line in entry.read_text().splitlines()
        if line.strip() and not line.lstrip().startswith("#") and len(line.split()) > 1
    )
    if target_init not in shlex.split(fields.get("options", "")):
        continue
    generation = re.match(r"Generation (\d+)\b", fields.get("version", ""))
    if generation:
        # Boot-counting suffixes change on boot; the entry ID does not.
        entry_id = re.sub(r"\+\d+(?:-\d+)?(?=\.conf$)", "", entry.name)
        matches.append((int(generation[1]), entry_id))

if not matches:
    raise SystemExit(f"No installed Fairydust boot entry matches {target_init}")

_, entry_id = max(matches)
loader_conf = loader_dir / "loader.conf"
lines = loader_conf.read_text().splitlines()
key = "preferred" if any(line.startswith("preferred ") for line in lines) else "default"
lines = [line for line in lines if not line.startswith(f"{key} ")]
lines.append(f"{key} {entry_id}")
temporary = loader_conf.with_suffix(".fairydust.tmp")
with temporary.open("w") as output:
    output.write("\n".join(lines) + "\n")
    output.flush()
    os.fsync(output.fileno())
temporary.replace(loader_conf)
print(f"Selected Fairydust boot default: {entry_id}")
