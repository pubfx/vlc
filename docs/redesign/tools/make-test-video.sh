#!/bin/bash
# Makes a 60 s 1080p test clip with 2 audio tracks (eng/fra) and 2 subtitle tracks
# (eng/fra), so the track and subtitle menus have something to list.
# Usage: docs/redesign/tools/make-test-video.sh [OUT.mkv]   (default ~/Videos/vlc-test.mkv)
set -eu
OUT=${1:-$HOME/Videos/vlc-test.mkv}
mkdir -p "$(dirname "$OUT")"
TMP=$(mktemp -d); trap 'rm -rf "$TMP"' EXIT

for lang in English Français; do
    f=$TMP/$lang.srt
    for i in $(seq 0 29); do
        printf '%d\n00:%02d:%02d,000 --> 00:%02d:%02d,500\n%s line %d\n\n' \
            $((i + 1)) $((i * 2 / 60)) $((i * 2 % 60)) $((i * 2 / 60)) $((i * 2 % 60 + 1)) "$lang" $((i + 1))
    done > "$f"
done

ffmpeg -loglevel error -y \
    -f lavfi -i "testsrc2=size=1920x1080:rate=30:duration=60" \
    -f lavfi -i "sine=frequency=440:duration=60" \
    -f lavfi -i "sine=frequency=660:duration=60" \
    -i "$TMP/English.srt" -i "$TMP/Français.srt" \
    -map 0 -map 1 -map 2 -map 3 -map 4 -c:v libx264 -preset veryfast -c:a aac -c:s srt \
    -metadata title="Redesign Test Clip" \
    -metadata:s:a:0 language=eng -metadata:s:a:1 language=fra \
    -metadata:s:s:0 language=eng -metadata:s:s:1 language=fra \
    "$OUT"
echo "saved $OUT"
