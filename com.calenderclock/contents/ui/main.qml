import QtQuick
import QtQuick.Layouts

import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami

PlasmoidItem {
    id: root

    readonly property string panelFontFamily: Plasmoid.configuration.panelFontFamily || "monospace"
    readonly property int panelFontSize: Plasmoid.configuration.panelFontSize || -1

    property color monthColor: "#a6adc8"
    property color weekdayColor: "#a6adc8"
    property color todayColor: "#a6adc8"
    property color dayColor: "#555869"

    property date now: new Date()
    property int shownYear: now.getFullYear()
    property int shownMonth: now.getMonth()
    property bool yearMode: false

    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            root.now = new Date();
            if (!root.expanded) {
                root.shownYear = root.now.getFullYear();
                root.shownMonth = root.now.getMonth();
            }
        }
    }

    function clockText() {
        return Qt.formatDateTime(root.now, "dddd  \uf272 dd MMMM  \uf43a HH:mm");
    }

    function monthName(y, m) {
        return Qt.formatDateTime(new Date(y, m, 1), "MMMM");
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
        root.shownYear = root.now.getFullYear();
        root.shownMonth = root.now.getMonth();
        root.yearMode = false;
    }

    function toggleMode() {
        root.yearMode = !root.yearMode;
    }

    function monthCells() {
        var y = root.shownYear;
        var m = root.shownMonth;
        var first = (new Date(y, m, 1).getDay() + 6) % 7;
        var daysInMonth = new Date(y, m + 1, 0).getDate();
        var daysInPrev = new Date(y, m, 0).getDate();
        var t = root.now;
        var ty = t.getFullYear(), tm = t.getMonth(), td = t.getDate();
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
                "isToday": inMonth && y === ty && m === tm && dayNum === td
            });
        }
        return cells;
    }

    preferredRepresentation: compactRepresentation
    activationTogglesExpanded: false

    toolTipMainText: clockText()
    toolTipSubText: monthName(root.shownYear, root.shownMonth) + " " + root.shownYear
        + "\nLeft-click: open calendar • Middle-click: today"
        + "\nDouble-click or press-and-hold: open calendar"

    Plasmoid.contextualActions: [
        PlasmaCore.Action {
            text: "Today"
            icon.name: "view-calendar-day"
            onTriggered: root.goToday()
        },
        PlasmaCore.Action {
            text: root.yearMode ? "Show month" : "Show year"
            icon.name: "view-calendar"
            onTriggered: root.toggleMode()
        }
    ]

    compactRepresentation: MouseArea {
        id: compactMouse
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton
        Layout.minimumWidth: clockLabel.implicitWidth + Kirigami.Units.smallSpacing * 2
        Layout.minimumHeight: clockLabel.implicitHeight
        Layout.preferredWidth: clockLabel.implicitWidth + Kirigami.Units.smallSpacing * 2
        Layout.preferredHeight: clockLabel.implicitHeight
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        PlasmaComponents.Label {
            id: clockLabel
            anchors.centerIn: parent
            text: root.clockText()
            font.family: root.panelFontFamily
            font.pointSize: root.panelFontSize
            font.bold: true
            // needs a Nerd Font for the icons
        }

        onClicked: function(mouse) {
            if (mouse.button === Qt.LeftButton) {
                root.expanded = !root.expanded;
            } else if (mouse.button === Qt.MiddleButton) {
                root.goToday();
                root.expanded = true;
            }
            mouse.accepted = true;
        }
        onDoubleClicked: function(mouse) {
            root.expanded = !root.expanded;
            mouse.accepted = true;
        }
        onPressAndHold: root.expanded = !root.expanded
    }

    fullRepresentation: ColumnLayout {
        id: popup
        Layout.minimumWidth: Kirigami.Units.gridUnit * 14
        Layout.minimumHeight: Kirigami.Units.gridUnit * 12
        Layout.preferredWidth: Kirigami.Units.gridUnit * 16
        spacing: Kirigami.Units.smallSpacing

        RowLayout {
            Layout.fillWidth: true
            PlasmaComponents.ToolButton {
                text: "<"
                onClicked: root.yearMode ? root.shiftYear(-1) : root.shiftMonth(-1)
            }
            PlasmaComponents.Label {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                font.bold: true
                color: root.monthColor
                font.family: "monospace"
                text: root.yearMode
                      ? root.shownYear
                      : root.monthName(root.shownYear, root.shownMonth) + " " + root.shownYear
            }
            PlasmaComponents.ToolButton {
                text: ">"
                onClicked: root.yearMode ? root.shiftYear(1) : root.shiftMonth(1)
            }
        }

        GridLayout {
            visible: !root.yearMode
            columns: 7
            Layout.fillWidth: true
            Repeater {
                model: ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]
                PlasmaComponents.Label {
                    required property string modelData
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    font.bold: true
                    font.family: "monospace"
                    color: root.weekdayColor
                    text: modelData
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
                    required property var modelData
                    Layout.fillWidth: true
                    Layout.preferredHeight: 28
                    radius: 4
                    color: modelData.isToday ? Qt.rgba(0.65, 0.68, 0.78, 0.18) : "transparent"
                    border.width: modelData.isToday ? 1 : 0
                    border.color: root.todayColor
                    opacity: modelData.inMonth ? 1.0 : 0.35

                    PlasmaComponents.Label {
                        anchors.centerIn: parent
                        font.bold: true
                        font.family: "monospace"
                        color: modelData.isToday ? root.todayColor : root.dayColor
                        text: modelData.day
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
                    required property int index
                    Layout.fillWidth: true
                    Layout.preferredHeight: 44
                    radius: 4
                    color: (root.shownMonth === index
                            && root.shownYear === root.now.getFullYear()
                            && root.now.getMonth() === index) ? Qt.rgba(0.65, 0.68, 0.78, 0.18) : "transparent"
                    border.width: root.shownMonth === index ? 1 : 0
                    border.color: root.monthColor

                    property bool isCurrentMonth: root.now.getFullYear() === root.shownYear && root.now.getMonth() === index

                    PlasmaComponents.Label {
                        anchors.centerIn: parent
                        font.bold: true
                        font.family: "monospace"
                        color: parent.isCurrentMonth ? root.todayColor : root.monthColor
                        text: root.monthName(root.shownYear, parent.index)
                    }
                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.LeftButton
                        onClicked: {
                            root.shownMonth = index;
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
            font.pointSize: 8
            text: "scroll: change month • right-click: month/year"
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.RightButton
            propagateComposedEvents: true
            onClicked: (mouse) => {
                if (mouse.button === Qt.RightButton) {
                    root.toggleMode();
                    mouse.accepted = true;
                } else {
                    mouse.accepted = false;
                }
            }
            onWheel: (wheel) => {
                if (root.yearMode) {
                    root.shiftYear(wheel.angleDelta.y > 0 ? -1 : 1);
                } else {
                    root.shiftMonth(wheel.angleDelta.y > 0 ? -1 : 1);
                }
            }
        }
    }
}
