#!/usr/bin/env bash
# Calender Clock - pre-release checks: metadata, config schema and QML lint.
set -euo pipefail
export LC_ALL=C.UTF-8

cd "$(dirname "${BASH_SOURCE[0]}")"
PKG="com.calenderclock"

python3 -m json.tool "$PKG/metadata.json" >/dev/null
echo "metadata.json OK"
python3 -c "import xml.dom.minidom; xml.dom.minidom.parse('$PKG/contents/config/main.xml')"
echo "main.xml OK"

LINT="$(command -v qmllint-qt6 || command -v qmllint || true)"
if [ -z "$LINT" ]; then
    echo "error: qmllint not found (Fedora: qt6-qtdeclarative-devel)" >&2
    exit 1
fi

# i18n() is provided by Plasma at runtime, so qmllint cannot resolve it.
# Those warnings are dropped; any other warning fails the check.
"$LINT" "$PKG"/contents/ui/*.qml 2>&1 | awk '
    /^Warning: / {
        warning = $0; getline source; getline carets
        token = substr(source, index(carets, "^"), gsub(/\^/, "^", carets))
        skip = (token == "i18n")
        if (!skip) { print warning; print source; print carets; bad++ }
        next
    }
    /^Info: / && skip { getline; getline; next }
    { print }
    END { exit bad > 0 }
'
echo "qmllint OK"
