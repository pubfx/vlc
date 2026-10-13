#!/bin/bash
# Screenshot a dev build of VLC on a headless 1920x1080 X display (Xvfb), to compare
# the player with a Figma frame. Works on WSL, where WSLg blocks screenshot tools.
#
# Usage: docs/redesign/tools/capture.sh [-t TREE] [-m MEDIA] [-k] [-a] OUT.png [-- VLC ARGS...]
#   -t TREE   VLC source tree that has a build/ dir (default: this repo)
#   -m MEDIA  media to play (default: ~/Videos/vlc-test.mkv, see make-test-video.sh)
#   -k        keep VLC running afterwards; drive it with `DISPLAY=:99 xdotool ...`
#             and capture again with `ffmpeg -f x11grab -video_size 1920x1080 -i :99 -frames:v 1 x.png`
#   -a        use the real audio output (default writes audio to /dev/null, because a
#             stuck WSLg PulseServer freezes VLC)
#
# VLC plays for a few seconds, pauses, then the mouse hovers the video so both bars show.
# Each tree gets its own config dir (~/.cache/vlc-redesign-capture/<tree>) so saved
# control-bar layouts don't leak between builds. The VLC log is written next to OUT.png.
#
# Needs: sudo apt install xvfb xdotool x11-utils ffmpeg
set -eu

REPO=$(cd "$(dirname "$0")/../../.." && pwd)
TREE=$REPO
MEDIA=$HOME/Videos/vlc-test.mkv
KEEP=
AUDIO=(--aout=afile --audiofile-file=/dev/null)
DISP=${CAPTURE_DISPLAY:-:99}

while getopts "t:m:ka" opt; do
    case $opt in
        t) TREE=$(cd "$OPTARG" && pwd) ;;
        m) MEDIA=$OPTARG ;;
        k) KEEP=1 ;;
        a) AUDIO=() ;;
        *) sed -n '2,20p' "$0"; exit 1 ;;
    esac
done
shift $((OPTIND - 1))
[ $# -ge 1 ] || { sed -n '2,20p' "$0"; exit 1; }
OUT=$1; shift
[ "${1:-}" = "--" ] && shift

for cmd in Xvfb xdotool xdpyinfo ffmpeg; do
    command -v $cmd >/dev/null || { echo "missing $cmd: sudo apt install xvfb xdotool x11-utils ffmpeg"; exit 1; }
done
VLC=$TREE/build/bin/vlc-static
[ -x "$VLC" ] || { echo "no build at $VLC (run: meson compile -C build)"; exit 1; }
[ -f "$MEDIA" ] || { echo "no media at $MEDIA (run: $REPO/docs/redesign/tools/make-test-video.sh)"; exit 1; }

# Fresh-ish config: skip the Welcome dialog (private option, not settable on the
# command line) and the "closed abruptly" recovery prompt left by a killed instance.
CFG=${CAPTURE_CFG:-$HOME/.cache/vlc-redesign-capture/$(basename "$TREE")}
mkdir -p "$CFG/vlc"
grep -qs '^qt-privacy-ask=0' "$CFG/vlc/vlcrc" || echo 'qt-privacy-ask=0' >> "$CFG/vlc/vlcrc"
sed -i '/RecoveryFilePath/d' "$CFG/vlc/vlc-qt-interface.conf" 2>/dev/null || true

if ! xdpyinfo -display $DISP >/dev/null 2>&1; then
    Xvfb $DISP -screen 0 1920x1080x24 +extension Composite +extension GLX -nolisten tcp >/dev/null 2>&1 &
    for _ in $(seq 50); do xdpyinfo -display $DISP >/dev/null 2>&1 && break; sleep 0.2; done
fi
export DISPLAY=$DISP QT_QPA_PLATFORM=xcb
export XDG_CONFIG_HOME=$CFG XDG_DATA_HOME=$CFG/data XDG_CACHE_HOME=$CFG/cache
unset WAYLAND_DISPLAY

pkill -9 -f "^$VLC" 2>/dev/null || true
"$VLC" --verbose=1 "${AUDIO[@]}" "$@" "$MEDIA" > "${OUT%.png}.log" 2>&1 &
VPID=$!
WID=$(timeout 30 xdotool search --sync --onlyvisible --pid $VPID --name "VLC media player" | head -1)
[ -n "$WID" ] || { echo "VLC window did not appear; log:"; cat "${OUT%.png}.log"; exit 1; }

xdotool windowmove $WID 0 0 windowsize $WID 1920 1080
sleep 4
xdotool key --window $WID space            # pause, so the frame and time are stable
sleep 0.5
xdotool mousemove 960 500; sleep 0.3; xdotool mousemove 970 510; sleep 1
ffmpeg -loglevel error -y -f x11grab -video_size 1920x1080 -i $DISP -frames:v 1 "$OUT"
echo "saved $OUT (log: ${OUT%.png}.log)"

if [ -n "$KEEP" ]; then
    echo "VLC still running: pid $VPID, window $WID, DISPLAY=$DISP"
else
    xdotool key --window $WID ctrl+q
    timeout 5 tail --pid=$VPID -f /dev/null || kill -9 $VPID
fi
