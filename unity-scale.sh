#!/bin/bash
# Starts Unity Hub with a tiny virtual 2x monitor.
# So the Unity Editor scales correctly on KDE Plasma (Wayland) with fractional scaling.

VIRTUAL_MONITOR_NAME="UnityHiDPI"
HUB_COMMAND="unityhub"

# Check dependencies.
for cmd in kscreen-doctor krfb-virtualmonitor "$HUB_COMMAND"; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "Missing required command: $cmd" >&2
        exit 1
    fi
done

# Just launch Unity if the virtual monitor already exists (e.g. another instance started it),
if kscreen-doctor -o 2>/dev/null | grep -q "$VIRTUAL_MONITOR_NAME"; then
    "$HUB_COMMAND"
    exit 0
fi

# Random password so nobody can connect.
PASSWORD=$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c 8)

# Find a free port.
PORT=5900
while ss -tln | grep -q ":$PORT "; do
    PORT=$((PORT + 1))
    if [ "$PORT" -gt 5999 ]; then
        echo "No free port found between 5900 and 5999" >&2
        exit 1
    fi
done

# Create the virtual monitor.
krfb-virtualmonitor \
    --resolution 1x1 \
    --scale 2 \
    --name "$VIRTUAL_MONITOR_NAME" \
    --password "$PASSWORD" \
    --port "$PORT" >/dev/null 2>&1 &
VIRTUAL_MONITOR_PID=$!

# Kill the monitor when this script exits.
cleanup() {
    kill "$VIRTUAL_MONITOR_PID" 2>/dev/null
}
trap cleanup EXIT
trap 'exit' INT TERM HUP

# Starts Unity Hub and wait for it to close.
"$HUB_COMMAND"

# Keep the monitor alive until every Unity Editor has closed.
while pgrep -f '/Editor/Unity( |$)' >/dev/null; do
    sleep 5
done
