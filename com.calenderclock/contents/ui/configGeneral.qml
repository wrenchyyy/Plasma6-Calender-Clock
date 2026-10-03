import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

// Font defaults to system monospace; -1 size means "follow the system".
KCM.SimpleKCM {
    id: page

    property string cfg_panelFontFamily
    property int cfg_panelFontSize
    property alias cfg_nerdFontIcons: nerdFontIcons.checked
    property alias cfg_useThemeColors: useThemeColors.checked

    // Plasma hands these to every config page.
    property string cfg_panelFontFamilyDefault
    property int cfg_panelFontSizeDefault
    property bool cfg_nerdFontIconsDefault
    property bool cfg_useThemeColorsDefault

    Kirigami.FormLayout {
        RowLayout {
            Kirigami.FormData.label: i18n("Panel font:")
            Label {
                Layout.fillWidth: true
                text: page.cfg_panelFontSize > 0
                      ? i18n("%1 %2pt", page.cfg_panelFontFamily, page.cfg_panelFontSize)
                      : i18n("%1 (system size)", page.cfg_panelFontFamily)
                font.family: page.cfg_panelFontFamily
                elide: Text.ElideRight
            }
            Button {
                text: i18n("Choose…")
                icon.name: "preferences-desktop-font"
                onClicked: {
                    fontDialog.selectedFont = Qt.font({
                        family: page.cfg_panelFontFamily,
                        pointSize: page.cfg_panelFontSize > 0 ? page.cfg_panelFontSize : 10
                    });
                    fontDialog.open();
                }
            }
            Button {
                text: i18n("Default")
                onClicked: {
                    page.cfg_panelFontFamily = "monospace";
                    page.cfg_panelFontSize = -1;
                }
            }
        }

        CheckBox {
            id: nerdFontIcons
            Kirigami.FormData.label: i18n("Panel icons:")
            text: i18n("Use Nerd Font glyphs (needs a Nerd Font as the panel font)")
        }

        CheckBox {
            id: useThemeColors
            Kirigami.FormData.label: i18n("Calendar colors:")
            text: i18n("Follow the Plasma color scheme")
        }
    }

    FontDialog {
        id: fontDialog
        title: i18n("Choose panel font")
        onAccepted: {
            page.cfg_panelFontFamily = fontDialog.selectedFont.family;
            page.cfg_panelFontSize = fontDialog.selectedFont.pointSize;
        }
    }
}
