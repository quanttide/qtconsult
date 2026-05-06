#!/usr/bin/env bash
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$SCRIPT_DIR/.."
STUDIO_BIN="$PROJECT_DIR/src/studio/build/linux/x64/release/bundle/studio"
VIDEO_OUT="$PROJECT_DIR/assets/videos/studio.mp4"

cleanup() {
  echo "Stopping..."
  local pid
  pid=$(pgrep -f "bundle/studio" 2>/dev/null || true)
  [ -n "$pid" ] && kill "$pid" 2>/dev/null || true
  pid=$(pgrep -f "ffmpeg.*x11grab" 2>/dev/null || true)
  [ -n "$pid" ] && kill "$pid" 2>/dev/null || true
}
trap cleanup EXIT

cleanup
sleep 1

echo "Starting studio..."
"$STUDIO_BIN" &
sleep 4

WID=$(xdotool search --name "量潮咨询" 2>/dev/null | head -1)
[ -z "$WID" ] && WID=$(xdotool search --name "com.quanttide.consult.studio" 2>/dev/null | head -1)
if [ -z "$WID" ]; then echo "ERROR: Cannot find window" >&2; exit 0; fi

xdotool windowsize "$WID" 1440 900 2>/dev/null || true
sleep 1

eval "$(xdotool getwindowgeometry --shell "$WID" 2>/dev/null)"
echo "Window at ${WIDTH}x${HEIGHT}"

ffmpeg -y -f x11grab -video_size "${WIDTH}x${HEIGHT}" -i ":0.0+${X},${Y}" \
  -framerate 30 -vf "pad=ceil(iw/2)*2:ceil(ih/2)*2" \
  -c:v libx264 -preset ultrafast -crf 18 -pix_fmt yuv420p "$VIDEO_OUT" &
FFMPEG_PID=$!
sleep 2

# Click 1: Observe column card checkbox (X=332, Y=148)
xdotool mousemove --window "$WID" 332 148
sleep 0.3
xdotool click --window "$WID" 1
sleep 1.5

# Click 2: Orient column "数据基建" filter (X=590, Y=105)
xdotool mousemove --window "$WID" 590 105
sleep 0.3
xdotool click --window "$WID" 1
sleep 1.2

# Click 3: Orient column cluster title collapse (X=410, Y=160)  
xdotool mousemove --window "$WID" 410 160
sleep 0.3
xdotool click --window "$WID" 1
sleep 1

# Click 4: Decide column strategy checkbox (X=753, Y=310)
xdotool mousemove --window "$WID" 753 310
sleep 0.3
xdotool click --window "$WID" 1
sleep 1.5

# Clear
xdotool mousemove --window "$WID" 1400 800
sleep 1

echo "Stopping recording..."
[ -n "$FFMPEG_PID" ] && kill "$FFMPEG_PID" 2>/dev/null || true
sleep 1
echo "Done! Video saved to $VIDEO_OUT"
