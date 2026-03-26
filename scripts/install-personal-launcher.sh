#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
APP_ID="limux-personal"
WRAPPER_PATH="$HOME/.local/bin/$APP_ID"
DESKTOP_PATH="$HOME/.local/share/applications/$APP_ID.desktop"
ICON_PATH="$ROOT_DIR/rust/limux-host-linux/icons/app/512.png"
BRANCH="$(git -C "$ROOT_DIR" branch --show-current 2>/dev/null || echo personal)"

mkdir -p "$HOME/.local/bin" "$HOME/.local/share/applications"

cargo build -p limux-host-linux --manifest-path "$ROOT_DIR/Cargo.toml"

cat > "$WRAPPER_PATH" <<EOF
#!/usr/bin/env bash
set -euo pipefail
REPO="$ROOT_DIR"
export LD_LIBRARY_PATH="\$REPO/ghostty/zig-out/lib\${LD_LIBRARY_PATH:+:\$LD_LIBRARY_PATH}"
exec "\$REPO/target/debug/limux" "\$@"
EOF
chmod 755 "$WRAPPER_PATH"

cat > "$DESKTOP_PATH" <<EOF
[Desktop Entry]
Version=1.0
Name=Limux Personal
Comment=Personal Limux build from $ROOT_DIR ($BRANCH)
Exec=$WRAPPER_PATH %U
TryExec=$WRAPPER_PATH
Icon=$ICON_PATH
Terminal=false
Type=Application
Categories=Utility;TerminalEmulator;
Keywords=terminal;multiplexer;ghostty;workspace;limux;personal;
StartupNotify=true
StartupWMClass=dev.limux.linux
X-GNOME-UsesNotifications=true
EOF

if command -v desktop-file-validate >/dev/null 2>&1; then
  desktop-file-validate "$DESKTOP_PATH"
fi

if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database "$HOME/.local/share/applications"
fi

if command -v omarchy-refresh-applications >/dev/null 2>&1; then
  omarchy-refresh-applications
fi

if command -v omarchy-restart-walker >/dev/null 2>&1; then
  omarchy-restart-walker
fi

printf 'Installed %s launcher for branch %s\n' "$APP_ID" "$BRANCH"
printf 'Desktop entry: %s\n' "$DESKTOP_PATH"

