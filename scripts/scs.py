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

if not lines:
    print("No screenshots found.")
    sys.exit()

input_text = "\n".join(lines)

first_uid = lines[0].split("\t")[0]
imv_proc = subprocess.Popen(["imv", str(Path.home() / "Pictures" / f"{first_uid}.png")])
imv_pid = imv_proc.pid

subprocess.run(
    ["fzf", "--delimiter=\t",
     f"--bind=focus:execute-silent(imv-msg {imv_pid} open ~/Pictures/{{1}}.png && imv-msg {imv_pid} goto -1)",
     f"--bind=enter:execute(sqlite3 {db_path} \"SELECT ocr FROM screenshots WHERE uid={{1}}\" | wl-copy)"],
    input=input_text,
    text=True
)

imv_proc.terminate()
