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

img = f"{pics}/{{1}}.png"
ocr_sql = "SELECT ocr FROM screenshots WHERE uid={1}"
preview_sql = (
    "SELECT coalesce(title,'Unknown') || char(10) || char(10) || coalesce(ocr,'') "
    "FROM screenshots WHERE uid={1}"
)

image_cmd = "chafa -f sixel -s ${FZF_PREVIEW_COLUMNS}x${FZF_PREVIEW_LINES} " + img
preview = (
    f'if [ "$FZF_PREVIEW_LABEL" = text ]; then sqlite3 {db_path} "{preview_sql}"; '
    f"else {image_cmd}; fi"
)

window = "up,65%"
to_text = f"change-preview-label(text)+change-preview-window({window},wrap)+refresh-preview"
to_image = f"change-preview-label(image)+change-preview-window({window})+refresh-preview"

subprocess.run(
    [
        "fzf",
        "--no-hscroll",
        f"--preview={preview}",
        "--preview-label=image",
        f"--preview-window={window}",
        f'--bind=ctrl-o:transform:[ "$FZF_PREVIEW_LABEL" = image ] && echo "{to_text}" || echo "{to_image}"',
        f"--bind=enter:execute-silent(imv {img} >/dev/null 2>&1 &)",
        f"--bind=alt-enter:execute-silent(wl-copy --type image/png < {img})",
        f'--bind=ctrl-y:execute-silent(sqlite3 {db_path} "{ocr_sql}" | wl-copy)',
        f"--bind=ctrl-i:execute-silent(wl-copy -n {img})",
        "--bind=ctrl-j:preview-down,ctrl-k:preview-up",
        f'--bind=ctrl-delete:execute-silent(rm {img} && sqlite3 {db_path} "DELETE FROM screenshots WHERE uid={{1}}")+reload({self_path} --list)+refresh-preview+down',
    ],
    input="\n".join(lines),
    text=True,
)
