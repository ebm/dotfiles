#!/usr/bin/env python3
import sqlite3
import subprocess
import sys
import uuid
import json
import multiprocessing

from pathlib import Path
from datetime import datetime


def find_focused(node):
    if node.get("focused"):
        return node
    for child in node.get("nodes", []) + node.get("floating_nodes", []):
        result = find_focused(child)
        if result:
            return result
    return None


def get_focused_window():
    result = subprocess.run(["swaymsg", "-t", "get_tree"], capture_output=True, text=True)
    tree = json.loads(result.stdout)
    node = find_focused(tree)
    if node:
        app_id = node.get("app_id") or node.get("window_properties", {}).get("class") or ""
        title = node.get("name") or ""
        return app_id, title
    return "", ""


def run_ocr(uid, path, db_path):
    tmp = path.replace(".png", ".tmp.png")
    subprocess.run(["magick", path, "-colorspace", "Gray", "-normalize", "-resize", "200%", tmp])
    result = subprocess.run(["tesseract", tmp, "-", "--psm", "11"], capture_output=True, text=True)
    subprocess.run(["rm", tmp])
    ocr_text = result.stdout.strip()
    conn = sqlite3.connect(db_path)
    conn.execute("UPDATE screenshots SET ocr = ? WHERE uid = ?", (ocr_text, uid))
    conn.commit()
    conn.close()


if __name__ == "__main__":
    fullscreen = "--fullscreen" in sys.argv

    folder = Path.home() / "Pictures"
    folder.mkdir(exist_ok=True)

    db_path = Path.home() / ".local" / "share" / "screenshots" / "screenshots.db"
    db_path.parent.mkdir(parents=True, exist_ok=True)

    uid = str(uuid.uuid4())[:8]
    while (folder / f"{uid}.png").exists():
        uid = str(uuid.uuid4())[:8]
    path = str(folder / f"{uid}.png")

    app_id, title = get_focused_window()
    db_title = app_id + "->" + title

    if fullscreen:
        subprocess.run(["grim", path])
    else:
        selection = subprocess.check_output(["slurp"]).decode().strip()
        subprocess.run(["grim", "-g", selection, path])

    with open(path, "rb") as f:
        subprocess.run(["wl-copy", "--type", "image/png"], stdin=f)

    db_date = datetime.now().strftime("%m/%d/%Y %I:%M:%S %p")

    conn = sqlite3.connect(str(db_path))
    conn.execute("""CREATE TABLE IF NOT EXISTS screenshots (
        uid TEXT PRIMARY KEY,
        date TEXT,
        title TEXT,
        ocr TEXT
    )""")
    conn.execute(
        "INSERT INTO screenshots (uid, date, title, ocr) VALUES (?, ?, ?, ?)",
        (uid, db_date, db_title, "")
    )
    conn.commit()
    conn.close()

    p = multiprocessing.Process(target=run_ocr, args=(uid, path, str(db_path)))
    p.start()
