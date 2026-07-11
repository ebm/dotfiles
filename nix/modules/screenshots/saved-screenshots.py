import sqlite3
import subprocess
import sys

from pathlib import Path

db_path = Path.home() / ".local" / "share" / "screenshots" / "screenshots.db"
pics = Path.home() / "Pictures"
self_path = Path(__file__).resolve()


def build_lines():
    if not db_path.exists():
        return []

    conn = sqlite3.connect(db_path)
    conn.execute(
        """CREATE TABLE IF NOT EXISTS screenshots (
        uid TEXT PRIMARY KEY,
        date TEXT,
        foreground TEXT,
        title TEXT,
        ocr TEXT
    )"""
    )

    rows = conn.execute(
        "SELECT uid, date, foreground, title, ocr FROM screenshots ORDER BY date DESC"
    ).fetchall()

    # Drop rows whose image is gone.
    kept = []
    for row in rows:
        if (pics / f"{row[0]}.png").exists():
            kept.append(row)
        else:
            conn.execute("DELETE FROM screenshots WHERE uid = ?", (row[0],))
    conn.commit()
    conn.close()

    if not kept:
        return []

    foreground_len = min(max(len(r[2]) for r in kept), 16)
    title_len = min(max(len(r[3]) for r in kept), 40)

    lines = []
    for uid, date, foreground, title, ocr in kept:
        flat = ocr.replace("\n", " ")
        lines.append(
            f"{uid}    {date}    {foreground:<{foreground_len}.{foreground_len}}    {title:<{title_len}.{title_len}}    {flat}"
        )
    return lines


if "--list" in sys.argv:
    print("\n".join(build_lines()))
    sys.exit()

lines = build_lines()
if not lines:
    print("No screenshots found.")
    sys.exit()

first_uid = lines[0].split()[0]
imv = subprocess.Popen(["imv", str(pics / f"{first_uid}.png")])

img = f"{pics}/{{1}}.png"
ocr_sql = "SELECT ocr FROM screenshots WHERE uid={1}"
preview_sql = (
    "SELECT coalesce(title,'Unknown') || char(10) || char(10) || coalesce(ocr,'') "
    "FROM screenshots WHERE uid={1}"
)

subprocess.run(
    [
        "fzf",
        "--no-hscroll",
        f'--preview=sqlite3 {db_path} "{preview_sql}"',
        "--preview-window=down:10:wrap",
        f"--bind=focus:execute-silent(imv-msg {imv.pid} open {img} && imv-msg {imv.pid} goto -1)",
        f'--bind=enter:execute(sqlite3 {db_path} "{ocr_sql}" | wl-copy)',
        f'--bind=ctrl-bspace:execute-silent(rm {img} && sqlite3 {db_path} "DELETE FROM screenshots WHERE uid={{1}}")+reload({self_path} --list)+refresh-preview+down',
    ],
    input="\n".join(lines),
    text=True,
)

imv.terminate()
