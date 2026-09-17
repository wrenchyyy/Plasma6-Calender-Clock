import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

// Font defaults to system monospace; -1 size means "follow the system".
KCM.SimpleKCM {
    property string cfg_panelFontFamily
    property int cfg_panelFontSize

    Kirigami.FormLayout {
        RowLayout {
            Kirigami.FormData.label: "Panel font:"
            Label {
                id: fontPreview
                Layout.fillWidth: true
                text: cfg_panelFontFamily + (cfg_panelFontSize > 0 ? " " + cfg_panelFontSize + "pt" : " (system size)")
                font.family: cfg_panelFontFamily
                elide: Text.ElideRight
            }
            Button {
                text: "Choose…"
                icon.name: "preferences-desktop-font"
                onClicked: fontDialog.open()
            }
            Button {
                text: "Default"
                onClicked: {
                    cfg_panelFontFamily = "monospace";
                    cfg_panelFontSize = -1;
                }
            }
        }

        FontDialog {
            id: fontDialog
            title: "Choose panel font"
            currentFont: Qt.font({
                family: cfg_panelFontFamily,
                pointSize: cfg_panelFontSize > 0 ? cfg_panelFontSize : 10
            })
            onAccepted: {
                cfg_panelFontFamily = font.family;
                cfg_panelFontSize = font.pointSize;
            }
        }
    }
}
