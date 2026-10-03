#!/usr/bin/env bash
# Calender Clock - Plasma 6 plasmoid installer
set -euo pipefail

WIDGET_ID="com.calenderclock"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$SCRIPT_DIR/$WIDGET_ID"

ICON_DEST_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/icons/hicolor/scalable/apps"

# Exact match against the installed list. (--show would also accept the
# source folder next to this script, so it cannot be used here.)
is_installed() {
    local list
    list="$(kpackagetool6 --type Plasma/Applet --list 2>/dev/null)" || return 1
    grep -qxF "$WIDGET_ID" <<<"$list"
}

case "${1:-}" in
    "") ;;
    --uninstall)
        if is_installed; then
            echo "==> Removing $WIDGET_ID ..."
            kpackagetool6 --type Plasma/Applet --remove "$WIDGET_ID"
        else
            echo "$WIDGET_ID is not installed."
        fi
        rm -f "$ICON_DEST_DIR/$WIDGET_ID.svg"
        kbuildsycoca6 >/dev/null 2>&1 || true
        exit 0
        ;;
    -h|--help)
        echo "usage: $0 [--uninstall]"
        exit 0
        ;;
    *)
        echo "usage: $0 [--uninstall]" >&2
        exit 2
        ;;
esac

if [ ! -d "$SRC" ]; then
    echo "error: widget source not found at $SRC" >&2
    exit 1
fi

if is_installed; then
    echo "==> Upgrading $WIDGET_ID ..."
    kpackagetool6 --type Plasma/Applet --upgrade "$SRC"
else
    echo "==> Installing $WIDGET_ID ..."
    kpackagetool6 --type Plasma/Applet --install "$SRC"
fi

# metadata.json names the icon "com.calenderclock", which Plasma looks up
# in the icon theme, so copy the bundled SVG there.
ICON_SRC="$SRC/contents/icons/calenderclock.svg"
if [ -f "$ICON_SRC" ]; then
    echo "==> Installing icon ..."
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
echo "Remove: $0 --uninstall"
