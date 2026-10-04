import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

// Font defaults to system monospace; -1 size means "follow the system".
KCM.SimpleKCM {
    id: page

    property alias cfg_showWeekday: showWeekday.checked
    property alias cfg_showDate: showDate.checked
    property alias cfg_showTime: showTime.checked
    property string cfg_language
    property string cfg_panelFontFamily
    property int cfg_panelFontSize
    property alias cfg_nerdFontIcons: nerdFontIcons.checked
    property alias cfg_useThemeColors: useThemeColors.checked

    // Plasma hands these to every config page.
    property bool cfg_showWeekdayDefault
    property bool cfg_showDateDefault
    property bool cfg_showTimeDefault
    property string cfg_languageDefault
    property string cfg_panelFontFamilyDefault
    property int cfg_panelFontSizeDefault
    property bool cfg_nerdFontIconsDefault
    property bool cfg_useThemeColorsDefault

    // Each language is listed under its own name, so it can be found whatever
    // the system language is. That is why these names are not translated.
    readonly property var languages: [
        { "code": "", "label": i18n("System default") },
        { "code": "id", "label": "Bahasa Indonesia" },
        { "code": "de", "label": "Deutsch" },
        { "code": "en", "label": "English" },
        { "code": "es", "label": "Español" },
        { "code": "fr", "label": "Français" },
        { "code": "it", "label": "Italiano" },
        { "code": "nl", "label": "Nederlands" },
        { "code": "pl", "label": "Polski" },
        { "code": "pt", "label": "Português" },
        { "code": "vi", "label": "Tiếng Việt" },
        { "code": "tr", "label": "Türkçe" },
        { "code": "ru", "label": "Русский" },
        { "code": "uk", "label": "Українська" },
        { "code": "ur", "label": "اردو" },
        { "code": "ar", "label": "العربية" },
        { "code": "fa", "label": "فارسی" },
        { "code": "ne", "label": "नेपाली" },
        { "code": "hi", "label": "हिन्दी" },
        { "code": "bn", "label": "বাংলা" }
    ]

    onCfg_languageChanged: languageBox.currentIndex = languageBox.indexOfValue(page.cfg_language)

    Kirigami.FormLayout {
        // The last ticked box cannot be unticked, so the panel is never empty.
        CheckBox {
            id: showWeekday
            Kirigami.FormData.label: i18n("Show in panel:")
            text: i18n("Weekday")
            enabled: !checked || showDate.checked || showTime.checked
        }

        CheckBox {
            id: showDate
            text: i18n("Date")
            enabled: !checked || showWeekday.checked || showTime.checked
        }

        CheckBox {
            id: showTime
            text: i18n("Time")
            enabled: !checked || showWeekday.checked || showDate.checked
        }

        ComboBox {
            id: languageBox
            Kirigami.FormData.label: i18n("Date language:")
            model: page.languages
            textRole: "label"
            valueRole: "code"
            onActivated: page.cfg_language = currentValue
            Component.onCompleted: currentIndex = indexOfValue(page.cfg_language)
        }

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
