pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami

PlasmoidItem {
    id: root

    readonly property string panelFontFamily: Plasmoid.configuration.panelFontFamily || "monospace"
    readonly property int panelFontSize: Plasmoid.configuration.panelFontSize > 0
                                         ? Plasmoid.configuration.panelFontSize
                                         : Kirigami.Theme.defaultFont.pointSize
    readonly property bool nerdFontIcons: Plasmoid.configuration.nerdFontIcons
    readonly property bool themeColors: Plasmoid.configuration.useThemeColors
    readonly property bool showWeekday: Plasmoid.configuration.showWeekday
    readonly property bool showDate: Plasmoid.configuration.showDate
    // With everything switched off the time stays, so the panel is never empty.
    readonly property bool showTime: Plasmoid.configuration.showTime || (!showWeekday && !showDate)

    readonly property color monthColor: themeColors ? Kirigami.Theme.textColor : "#a6adc8"
    readonly property color weekdayColor: themeColors ? Kirigami.Theme.textColor : "#a6adc8"
    readonly property color dayColor: themeColors ? Kirigami.Theme.textColor : "#555869"
    readonly property color otherDayColor: themeColors ? Kirigami.Theme.disabledTextColor
                                                       : Qt.rgba(dayColor.r, dayColor.g, dayColor.b, 0.35)
    readonly property color todayColor: themeColors ? Kirigami.Theme.highlightedTextColor : "#a6adc8"
    readonly property color todayBackground: themeColors ? Kirigami.Theme.highlightColor
                                                         : Qt.rgba(0.65, 0.68, 0.78, 0.18)
    readonly property color todayBorderColor: themeColors ? Kirigami.Theme.highlightColor : "#a6adc8"

    property date now: new Date()
    readonly property int todayYear: now.getFullYear()
    readonly property int todayMonth: now.getMonth()
    readonly property int todayDay: now.getDate()
    property int shownYear: todayYear
    property int shownMonth: todayMonth
    property bool yearMode: false

    // An empty language follows the system. The chosen one sets names and digits only.
    readonly property string language: Plasmoid.configuration.language
    readonly property var dateLocale: language ? Qt.locale(language) : Qt.locale()

    // 0 = Sunday, like Date.getDay(). The week start stays with the system region.
    readonly property int firstDayOfWeek: Qt.locale().firstDayOfWeek

    function refresh() {
        root.now = new Date();
        if (!root.expanded) {
            root.shownYear = root.todayYear;
            root.shownMonth = root.todayMonth;
        }
    }

    function msToNextMinute() {
        return 60000 - Date.now() % 60000;
    }

    // Ticks on the minute boundary instead of polling.
    Timer {
        id: minuteTimer
        interval: root.msToNextMinute()
        running: true
        onTriggered: {
            root.refresh();
            minuteTimer.interval = root.msToNextMinute();
            minuteTimer.restart();
        }
    }

    onExpandedChanged: root.refresh()

    // Qt.formatDateTime() with a format string always gives English names and
    // digits, so every date goes through dateLocale instead.
    function timeText() {
        return root.now.toLocaleTimeString(root.dateLocale, "HH:mm");
    }

    function monthName(m) {
        return root.dateLocale.standaloneMonthName(m, Locale.LongFormat);
    }

    function yearText(y) {
        return new Date(y, 0, 1).toLocaleDateString(root.dateLocale, "yyyy");
    }

    function shiftMonth(delta) {
        var d = new Date(root.shownYear, root.shownMonth + delta, 1);
        root.shownYear = d.getFullYear();
        root.shownMonth = d.getMonth();
    }

    function shiftYear(delta) {
        root.shownYear += delta;
    }

    function goToday() {
        root.shownYear = root.todayYear;
        root.shownMonth = root.todayMonth;
        root.yearMode = false;
    }

    function toggleMode() {
        root.yearMode = !root.yearMode;
    }

    function monthCells() {
        var y = root.shownYear;
        var m = root.shownMonth;
        var first = (new Date(y, m, 1).getDay() - root.firstDayOfWeek + 7) % 7;
        var daysInMonth = new Date(y, m + 1, 0).getDate();
        var daysInPrev = new Date(y, m, 0).getDate();
        var thisMonth = y === root.todayYear && m === root.todayMonth;
        var cells = [];
        for (var i = 0; i < 42; i++) {
            var dayNum, inMonth;
            if (i < first) {
                dayNum = daysInPrev - first + 1 + i;
                inMonth = false;
            } else if (i < first + daysInMonth) {
                dayNum = i - first + 1;
                inMonth = true;
            } else {
                dayNum = i - (first + daysInMonth) + 1;
                inMonth = false;
            }
            cells.push({
                "day": dayNum,
                "inMonth": inMonth,
                "isToday": inMonth && thisMonth && dayNum === root.todayDay
            });
        }
        return cells;
    }

    preferredRepresentation: compactRepresentation

    toolTipMainText: root.now.toLocaleString(root.dateLocale, "dddd dd MMMM  HH:mm")
    toolTipSubText: root.monthName(root.shownMonth) + " " + root.yearText(root.shownYear)
        + "\n" + i18n("Left-click: open calendar • Middle-click: today")

    Plasmoid.contextualActions: [
        PlasmaCore.Action {
            text: i18n("Today")
            icon.name: "view-calendar-day"
            onTriggered: root.goToday()
        },
        PlasmaCore.Action {
            text: root.yearMode ? i18n("Show month") : i18n("Show year")
            icon.name: "view-calendar"
            onTriggered: root.toggleMode()
        }
    ]

    compactRepresentation: MouseArea {
        id: compactMouse

        // A vertical panel is too narrow for the full line: show the time only, on two lines.
        readonly property bool vertical: Plasmoid.formFactor === PlasmaCore.Types.Vertical
        readonly property bool showThemeIcons: !root.nerdFontIcons && !vertical
        readonly property int iconSize: Math.round(timeLabel.contentHeight * 0.8)
        property bool wasExpanded: false

        acceptedButtons: Qt.LeftButton | Qt.MiddleButton
        Layout.minimumWidth: clockRow.implicitWidth + Kirigami.Units.smallSpacing * 2
        Layout.minimumHeight: clockRow.implicitHeight
        Layout.preferredWidth: clockRow.implicitWidth + Kirigami.Units.smallSpacing * 2
        Layout.preferredHeight: clockRow.implicitHeight
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        Accessible.name: root.toolTipMainText
        Accessible.role: Accessible.Button
        Accessible.onPressAction: root.expanded = !root.expanded

        RowLayout {
            id: clockRow
            anchors.centerIn: parent
            spacing: Kirigami.Units.largeSpacing

            PlasmaComponents.Label {
                visible: root.showWeekday && !compactMouse.vertical
                text: root.now.toLocaleDateString(root.dateLocale, "dddd")
                font.family: root.panelFontFamily
                font.pointSize: root.panelFontSize
                font.bold: true
            }

            RowLayout {
                visible: root.showDate && !compactMouse.vertical
                spacing: Kirigami.Units.smallSpacing

                Kirigami.Icon {
                    visible: compactMouse.showThemeIcons
                    source: "view-calendar-day-symbolic"
                    implicitWidth: compactMouse.iconSize
                    implicitHeight: compactMouse.iconSize
                }
                PlasmaComponents.Label {
                    // the glyph needs a Nerd Font
                    text: (root.nerdFontIcons ? " " : "") + root.now.toLocaleDateString(root.dateLocale, "dd MMMM")
                    font.family: root.panelFontFamily
                    font.pointSize: root.panelFontSize
                    font.bold: true
                }
            }

            RowLayout {
                visible: root.showTime || compactMouse.vertical
                spacing: Kirigami.Units.smallSpacing

                Kirigami.Icon {
                    visible: compactMouse.showThemeIcons
                    source: "clock-symbolic"
                    implicitWidth: compactMouse.iconSize
                    implicitHeight: compactMouse.iconSize
                }
                PlasmaComponents.Label {
                    id: timeLabel
                    text: compactMouse.vertical
                          ? root.now.toLocaleTimeString(root.dateLocale, "HH\nmm")
                          : (root.nerdFontIcons ? " " : "") + root.timeText()
                    horizontalAlignment: Text.AlignHCenter
                    font.family: root.panelFontFamily
                    font.pointSize: root.panelFontSize
                    font.bold: true
                }
            }
        }

        // The popup closes itself when the panel is pressed; without this the click would reopen it.
        onPressed: wasExpanded = root.expanded
        onClicked: mouse => {
            if (mouse.button === Qt.MiddleButton) {
                root.goToday();
                root.expanded = true;
            } else {
                root.expanded = !wasExpanded;
            }
        }
        onPressAndHold: root.expanded = !wasExpanded
    }

    fullRepresentation: Item {
        id: popup

        readonly property int wantedHeight: Math.max(Kirigami.Units.gridUnit * 12, column.implicitHeight)
        property int wheelAccum: 0

        Layout.minimumWidth: Kirigami.Units.gridUnit * 14
        Layout.minimumHeight: wantedHeight
        Layout.preferredWidth: Kirigami.Units.gridUnit * 16
        Layout.preferredHeight: wantedHeight

        ColumnLayout {
            id: column
            anchors.fill: parent
            spacing: Kirigami.Units.smallSpacing

            RowLayout {
                Layout.fillWidth: true
                PlasmaComponents.ToolButton {
                    text: "<"
                    Accessible.name: root.yearMode ? i18n("Previous year") : i18n("Previous month")
                    onClicked: root.yearMode ? root.shiftYear(-1) : root.shiftMonth(-1)
                }
                PlasmaComponents.Label {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    font.bold: true
                    color: root.monthColor
                    font.family: "monospace"
                    text: root.yearMode
                          ? root.yearText(root.shownYear)
                          : root.monthName(root.shownMonth) + " " + root.yearText(root.shownYear)
                }
                PlasmaComponents.ToolButton {
                    text: ">"
                    Accessible.name: root.yearMode ? i18n("Next year") : i18n("Next month")
                    onClicked: root.yearMode ? root.shiftYear(1) : root.shiftMonth(1)
                }
            }

            GridLayout {
                visible: !root.yearMode
                columns: 7
                Layout.fillWidth: true
                Repeater {
                    model: 7
                    PlasmaComponents.Label {
                        required property int index
                        Layout.fillWidth: true
                        // equal columns, whatever the name lengths
                        Layout.preferredWidth: 1
                        // some languages have long short names: shrink those to fit the column
                        fontSizeMode: Text.HorizontalFit
                        minimumPointSize: 5
                        elide: Text.ElideRight
                        horizontalAlignment: Text.AlignHCenter
                        font.bold: true
                        font.family: "monospace"
                        color: root.weekdayColor
                        text: root.dateLocale.dayName((root.firstDayOfWeek + index) % 7, Locale.ShortFormat)
                    }
                }
            }

            GridLayout {
                visible: !root.yearMode
                columns: 7
                Layout.fillWidth: true
                Layout.fillHeight: true
                rowSpacing: 2
                columnSpacing: 2
                Repeater {
                    model: root.monthCells()
                    delegate: Rectangle {
                        id: dayCell
                        required property var modelData
                        Layout.fillWidth: true
                        Layout.preferredWidth: 1
                        Layout.preferredHeight: Math.round(Kirigami.Units.gridUnit * 1.5)
                        radius: 4
                        color: dayCell.modelData.isToday ? root.todayBackground : "transparent"
                        border.width: dayCell.modelData.isToday ? 1 : 0
                        border.color: root.todayBorderColor

                        PlasmaComponents.Label {
                            anchors.centerIn: parent
                            font.bold: true
                            font.family: "monospace"
                            color: dayCell.modelData.isToday ? root.todayColor
                                 : dayCell.modelData.inMonth ? root.dayColor : root.otherDayColor
                            text: dayCell.modelData.day.toLocaleString(root.dateLocale, "f", 0)
                        }
                    }
                }
            }

            GridLayout {
                visible: root.yearMode
                columns: 3
                Layout.fillWidth: true
                Layout.fillHeight: true
                rowSpacing: 4
                columnSpacing: 4
                Repeater {
                    model: 12
                    delegate: Rectangle {
                        id: monthCell
                        required property int index
                        readonly property bool isCurrentMonth: root.todayYear === root.shownYear
                                                               && root.todayMonth === index
                        Layout.fillWidth: true
                        Layout.preferredWidth: 1
                        Layout.preferredHeight: Math.round(Kirigami.Units.gridUnit * 2.5)
                        radius: 4
                        color: monthCell.isCurrentMonth ? root.todayBackground : "transparent"
                        border.width: root.shownMonth === monthCell.index ? 1 : 0
                        border.color: root.todayBorderColor

                        PlasmaComponents.Label {
                            anchors.centerIn: parent
                            font.bold: true
                            font.family: "monospace"
                            color: monthCell.isCurrentMonth ? root.todayColor : root.monthColor
                            text: root.monthName(monthCell.index)
                        }
                        MouseArea {
                            anchors.fill: parent
                            acceptedButtons: Qt.LeftButton
                            onClicked: {
                                root.shownMonth = monthCell.index;
                                root.yearMode = false;
                            }
                        }
                    }
                }
            }

            PlasmaComponents.Label {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                opacity: 0.5
                font: Kirigami.Theme.smallFont
                text: root.yearMode ? i18n("Scroll: change year • Right-click: month view")
                                    : i18n("Scroll: change month • Right-click: year view")
            }
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.RightButton
            onClicked: root.toggleMode()
            onWheel: wheel => {
                // One step per full notch, so touchpads don't race through months.
                popup.wheelAccum += wheel.angleDelta.y;
                while (Math.abs(popup.wheelAccum) >= 120) {
                    const step = popup.wheelAccum > 0 ? -1 : 1;
                    popup.wheelAccum += step * 120;
                    if (root.yearMode) {
                        root.shiftYear(step);
                    } else {
                        root.shiftMonth(step);
                    }
                }
            }
        }
    }
}
