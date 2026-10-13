#!/usr/bin/env python3
"""Measure colors and sizes in a screenshot, e.g. a capture.sh image vs a Figma export.

Usage: measure.py IMAGE QUERY...
  x,y               color of one pixel
  col:x:y0:y1       runs of equal color down column x  -> heights (seek bar, buttons)
  row:y:x0:x1       runs of equal color along row y    -> widths
  max:x0:y0:x1:y1   brightest pixel in a box           -> text / icon color

Example: measure.py ours.png col:800:1000:1079 max:170:1040:240:1062
Needs only ffmpeg/ffprobe (no Python packages).
"""
import subprocess
import sys


def load(path):
    probe = subprocess.run(["ffprobe", "-v", "error", "-select_streams", "v:0", "-show_entries",
                            "stream=width,height", "-of", "csv=p=0", path],
                           capture_output=True, text=True, check=True)
    w, h = map(int, probe.stdout.strip().split(","))
    raw = subprocess.run(["ffmpeg", "-v", "error", "-i", path, "-f", "rawvideo", "-pix_fmt", "rgb24", "-"],
                         capture_output=True, check=True).stdout
    return w, h, raw


def px(img, x, y):
    w, _, raw = img
    i = (y * w + x) * 3
    return "#%02X%02X%02X" % (raw[i], raw[i + 1], raw[i + 2])


def runs(img, coords):
    """[(first_index, last_index, color)] for consecutive equal colors along coords."""
    out, last, start = [], None, 0
    for k, (x, y) in enumerate(coords):
        c = px(img, x, y)
        if c != last:
            if last is not None:
                out.append((start, k - 1, last))
            last, start = c, k
    out.append((start, len(coords) - 1, last))
    return out


def brightest(img, x0, y0, x1, y1):
    best_v, best_c = -1, None
    for y in range(y0, y1 + 1):
        for x in range(x0, x1 + 1):
            c = px(img, x, y)
            v = sum(int(c[i:i + 2], 16) for i in (1, 3, 5))
            if v > best_v:
                best_v, best_c = v, c
    return best_c


def main():
    if len(sys.argv) < 3:
        sys.exit(__doc__)
    img = load(sys.argv[1])
    for q in sys.argv[2:]:
        if ":" in q:
            kind, *nums = q.split(":")
        else:
            kind, nums = "px", q.split(",")
        n = list(map(int, nums))
        if kind == "col":
            x, y0, y1 = n
            res = [(y0 + s, y0 + e, c) for s, e, c in runs(img, [(x, y) for y in range(y0, y1 + 1)])]
            print(q, " ".join(f"{a}-{b}({b - a + 1}px){c}" for a, b, c in res))
        elif kind == "row":
            y, x0, x1 = n
            res = [(x0 + s, x0 + e, c) for s, e, c in runs(img, [(x, y) for x in range(x0, x1 + 1)])]
            print(q, " ".join(f"{a}-{b}({b - a + 1}px){c}" for a, b, c in res))
        elif kind == "max":
            print(q, brightest(img, *n))
        else:
            print(q, px(img, *n))


if __name__ == "__main__":
    main()
