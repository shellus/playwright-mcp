#!/bin/bash
set -e

# Clean up stale locks
rm -f /tmp/.X99-lock

# Start Xvfb
Xvfb :99 -screen 0 1920x1080x24 &
sleep 2
export DISPLAY=:99

# Start x11vnc
x11vnc -display :99 -forever -shared -rfbport 5900 -passwd ${VNC_PASSWORD:-playwright} &

# Start noVNC websockify
websockify --web=/usr/share/novnc 6080 localhost:5900 &

# Start Chrome with CDP enabled (persistent browser)
mkdir -p /data/chrome-profile
google-chrome \
  --no-sandbox \
  --disable-gpu \
  --disable-dev-shm-usage \
  --remote-debugging-port=9222 \
  --user-data-dir=/data/chrome-profile \
  --no-first-run \
  --start-maximized \
  "about:blank" &

# Wait for Chrome CDP to be ready and get WebSocket URL
echo "Waiting for Chrome CDP..."
WS_URL=""
for i in {1..30}; do
  WS_URL=$(curl -s http://localhost:9222/json/version | grep -o '"webSocketDebuggerUrl": "[^"]*"' | cut -d'"' -f4)
  if [ -n "$WS_URL" ]; then
    echo "Chrome CDP ready: $WS_URL"
    break
  fi
  sleep 1
done

if [ -z "$WS_URL" ]; then
  echo "Failed to get Chrome WebSocket URL"
  exit 1
fi

# Start Playwright MCP connecting to existing Chrome
exec node /app/cli.js \
  --port 8931 \
  --host 0.0.0.0 \
  --allowed-hosts '*' \
  --caps vision,pdf \
  --cdp-endpoint "$WS_URL"
