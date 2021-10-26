/*

This file is part of Septitrac.
Copyright 2021, Michał Szczepaniak <m.szczepaniak.000@gmail.com>

Septitrac is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Septitrac is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Septitrac. If not, see <http://www.gnu.org/licenses/>.

*/

import QtQuick 2.0
import Sailfish.Silica 1.0
import "../pages/components"
import "../js/humanized_time_span.js" as HumanizedTimeSpan

CoverBackground {

    Column {
        anchors.centerIn: parent
        width: parent.width - Theme.paddingSmall*2

        Label {
            id: label
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("Septitrac")
            font.bold: true
            font.pixelSize: Theme.fontSizeLarge
        }

        Item {
            height: Theme.paddingLarge
            width: 1
        }

        DeviceProperty {
            width: Math.min(implicitWidth, parent.width)
            anchors.horizontalCenter: parent.horizontalCenter
            name: qsTr("Name:")
        }

        DeviceProperty {
            width: Math.min(implicitWidth, parent.width)
            anchors.horizontalCenter: parent.horizontalCenter
            value: app.coverSelectedDevice.name
        }

        DeviceProperty {
            width: Math.min(implicitWidth, parent.width)
            anchors.horizontalCenter: parent.horizontalCenter
            name: qsTr("Status:")
        }

        DeviceProperty {
            width: Math.min(implicitWidth, parent.width)
            anchors.horizontalCenter: parent.horizontalCenter
            value: app.coverSelectedDevice.status
        }

        DeviceProperty {
            width: Math.min(implicitWidth, parent.width)
            anchors.horizontalCenter: parent.horizontalCenter
            name: qsTr("Last update:")
        }

        DeviceProperty {
            width: Math.min(implicitWidth, parent.width)
            anchors.horizontalCenter: parent.horizontalCenter
            value: HumanizedTimeSpan.humanized_time_span(new Date(app.coverSelectedDevice.lastUpdate))
        }
    }
}
