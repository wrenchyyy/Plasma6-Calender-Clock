#!/usr/bin/env bash
# Calender Clock - Plasma 6 plasmoid installer
set -euo pipefail

WIDGET_ID="com.calenderclock"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$SCRIPT_DIR/$WIDGET_ID"

if [ ! -d "$SRC" ]; then
    echo "error: widget source not found at $SRC" >&2
    exit 1
fi

if kpackagetool6 --type Plasma/Applet --list 2>/dev/null | grep -q "$WIDGET_ID"; then
    echo "==> Upgrading $WIDGET_ID ..."
    kpackagetool6 --type Plasma/Applet --upgrade "$SRC"
else
    echo "==> Installing $WIDGET_ID ..."
    kpackagetool6 --type Plasma/Applet --install "$SRC"
fi

# Fallback icon for places that only look up the system icon theme
# (e.g. the Configure dialog's About page): the widget browser itself
# uses the icon bundled at contents/icons/calenderclock.svg instead.
ICON_SRC="$SRC/contents/icons/calenderclock.svg"
ICON_DEST_DIR="$HOME/.local/share/icons/hicolor/scalable/apps"
if [ -f "$ICON_SRC" ]; then
    echo "==> Installing fallback icon ..."
    mkdir -p "$ICON_DEST_DIR"
    cp "$ICON_SRC" "$ICON_DEST_DIR/$WIDGET_ID.svg"
    kbuildsycoca6 >/dev/null 2>&1 || true
fi

echo ""
echo "Done! Add it to your top bar:"
echo "  Right-click the top panel -> Edit Panel -> Add Widgets -> search 'Calender Clock'"
echo ""
echo "Use: left-click opens calendar, middle-click jumps to today."
echo "Config: right-click widget -> Configure."
