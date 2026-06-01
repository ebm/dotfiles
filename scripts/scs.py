#!/usr/bin/env python3

import sqlite3
import subprocess
import sys

from pathlib import Path

db_path = Path.home() / ".local" / "share" / "screenshots" / "screenshots.db"
if not db_path.exists():
    print("No screenshots found.")
    sys.exit()

conn = sqlite3.connect(str(db_path))
rows = conn.execute("SELECT * FROM screenshots ORDER BY date DESC").fetchall()

lines = []
for uid, date, title, ocr in rows:
    if not (Path.home() / "Pictures" / f"{uid}.png").exists():
        conn.execute("DELETE FROM screenshots WHERE uid = ?", (uid,))
        continue
    lines.append(f"{uid}\t{date}\t{title}\t{ocr.replace('\n', ' ')}")

conn.commit()
conn.close()

input_text = "\n".join(lines)
subprocess.run(
    ["fzf", "--delimiter=\t", "--bind=enter:execute(imv ~/Pictures/{1}.png)",
     f"--bind=ctrl-y:execute(sqlite3 {db_path} \"SELECT ocr FROM screenshots WHERE uid={{1}}\" | wl-copy)"],
    input=input_text,
    text=True
)
