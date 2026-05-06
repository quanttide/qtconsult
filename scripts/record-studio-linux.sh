#!/usr/bin/env bash
# Record qtconsult-studio OODA consulting board demo
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$SCRIPT_DIR/.."
STUDIO_BIN="$PROJECT_DIR/src/studio/build/linux/x64/release/bundle/studio"
VIDEO_OUT="$PROJECT_DIR/assets/videos/studio.mp4"

WINFO_FILE="/tmp/qtconsult_win.txt"

cleanup() {
  echo ""
  echo "Stopping..."
  local pid
  pid=$(pgrep -f "bundle/studio" 2>/dev/null || true)
  [ -n "$pid" ] && kill "$pid" 2>/dev/null || true
  pid=$(pgrep -f "ffmpeg.*x11grab" 2>/dev/null || true)
  [ -n "$pid" ] && kill "$pid" 2>/dev/null || true
  xdotool mousemove 0 0 2>/dev/null || true
  rm -f "$WINFO_FILE"
}
trap cleanup EXIT

cleanup
sleep 1

echo "Starting studio..."
"$STUDIO_BIN" &
sleep 4

WID=$(xdotool search --name "com.quanttide.consult.studio" 2>/dev/null | head -1)
if [ -z "$WID" ]; then
  WID=$(xdotool search --name "studio" 2>/dev/null | tail -1)
fi
if [ -z "$WID" ]; then
  echo "ERROR: Cannot find content window" >&2
  exit 0
fi
echo "Content Window ID: $WID"
xdotool getwindowgeometry "$WID"
echo "Window name: $(xdotool getwindowname "$WID")"

xdotool windowsize "$WID" 1440 900
sleep 1

eval "$(xdotool getwindowgeometry --shell "$WID")"
echo "CONTENT_X=$X CONTENT_Y=$Y CONTENT_W=$WIDTH CONTENT_H=$HEIGHT"
echo "$X $Y $WIDTH $HEIGHT" > "$WINFO_FILE"

xdotool windowactivate --sync "$WID"
xdotool windowraise "$WID"
sleep 1

echo "Recording window area to $VIDEO_OUT..."
ffmpeg -y -f x11grab -video_size "${WIDTH}x${HEIGHT}" -i ":0.0+${X},${Y}" \
  -framerate 30 -vf "pad=ceil(iw/2)*2:ceil(ih/2)*2" \
  -c:v libx264 -preset ultrafast -crf 18 -pix_fmt yuv420p "$VIDEO_OUT" &
FFMPEG_PID=$!
sleep 2

xdotool windowactivate --sync "$WID"
xdotool windowraise "$WID"
sleep 0.5

# === Gesture coordinates (window-relative, for 1440x900 layout) ===
# Header: 20px top padding + header = ~50px
# Columns start at ~50px from top
# Column widths: Observe=340, Orient=340, Decide=410, Act=270
# Column X starts: Observe=16, Orient=370, Decide=724, Act=1148

click_win() {
  xdotool windowactivate --sync "$WID" 2>/dev/null || true
  xdotool mousemove --window "$WID" "$1" "$2" click 1
  sleep "$3"
}

# ===== Interactions =====

# 1. Observe column: click first pending card checkbox
click_win 370 165 1.5

# 2. Orient column: switch filter to "数据基建"
click_win 555 120 1
sleep 1

# 3. Orient column: switch filter back to "全部"
click_win 420 120 1
sleep 1

# 4. Orient column: collapse first cluster
click_win 410 155 1
sleep 1.5

# 5. Orient column: expand first cluster
click_win 410 155 1
sleep 1

# 6. Decide column: toggle strategy B selection
click_win 940 280 1.5
sleep 1

# 7. Decide column: toggle strategy B back off
click_win 940 280 1
sleep 0.5

# 8. Decide column: click strategy A checkbox
click_win 940 215 1
sleep 1
click_win 940 215 1
sleep 1

# 9. Scroll down in Decide column
xdotool windowactivate --sync "$WID" 2>/dev/null || true
xdotool mousemove --window "$WID" 920 500
xdotool click --window "$WID" 5
sleep 1.5

# 10. Scroll back up
xdotool click --window "$WID" 4
sleep 1

# 11. Show Act column
xdotool mousemove --window "$WID" 1280 350
sleep 1

xdotool windowactivate --sync "$WID" 2>/dev/null || true
xdotool mousemove --window "$WID" 1400 800
sleep 1

echo "Stopping recording..."
[ -n "$FFMPEG_PID" ] && kill "$FFMPEG_PID" 2>/dev/null || true
sleep 2

echo "Done! Video saved to $VIDEO_OUT"
