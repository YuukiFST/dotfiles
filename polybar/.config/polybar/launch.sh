#!/run/current-system/sw/bin/bash

# NixOS: /bin/env não existe; usar caminhos explícitos para o i3 iniciar no boot
PKILL="${PKILL:-/run/current-system/sw/bin/pkill}"
PGREP="${PGREP:-/run/current-system/sw/bin/pgrep}"
POLYBAR="${POLYBAR:-/run/current-system/sw/bin/polybar}"
FLOCK="${FLOCK:-/run/current-system/sw/bin/flock}"

# Evita duas barras quando i3 reload e launch.sh rodam ao mesmo tempo
exec 9>/tmp/polybar-launch.lock
if ! "$FLOCK" -n 9; then
  exit 0
fi

# Terminate already running bars
"$PKILL" -x polybar 2>/dev/null || true

# Wait until bars have been terminated
while "$PGREP" -u "$UID" -x polybar >/dev/null; do sleep 0.2; done

# Launch Polybar on each monitor
for m in $("$POLYBAR" --list-monitors | cut -d":" -f1); do
    MONITOR=$m "$POLYBAR" --reload top &
done
