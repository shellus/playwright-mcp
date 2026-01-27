#!/bin/bash
set -e

# Disable Chrome sandbox for root user
export PLAYWRIGHT_CHROMIUM_SANDBOX=false

# Clean up stale X lock
rm -f /tmp/.X99-lock

# Start Xvfb
Xvfb :99 -screen 0 1920x1080x24 &
sleep 2
export DISPLAY=:99

# Start x11vnc
x11vnc -display :99 -forever -shared -rfbport 5900 -passwd ${VNC_PASSWORD:-playwright} &

# Start noVNC websockify
websockify --web=/usr/share/novnc 6080 localhost:5900 &

# Start Playwright MCP (use node cli.js directly)
exec node /app/cli.js --port 8931 --host 0.0.0.0 --allowed-hosts '*' --caps vision,pdf --no-sandbox
