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
import QtPositioning 5.3
import MapboxMap 1.0
import "components"
import "../js/humanized_time_span.js" as HumanizedTimeSpan

Page {
    id: page

    allowedOrientations: Orientation.All

    Connections {
        target: apiClient

        onPositionsChanged: {
            var parsedPositions = JSON.parse(apiClient.positions);
            if (parsedPositions.length > 0) map.center = QtPositioning.coordinate(parsedPositions[0].latitude, parsedPositions[0].longitude)
            map.updatePositions()
        }

        onDevicesChanged: map.updatePositions()
    }

    SilicaFlickable {
        anchors.fill: parent

        PullDownMenu {
            MenuItem {
                text: qsTr("About")
                onClicked: pageStack.animatorPush(Qt.resolvedUrl("About.qml"))
            }

            MenuItem {
                text: qsTr("Settings")
                onClicked: pageStack.animatorPush(Qt.resolvedUrl("Settings.qml"))
            }

            MenuItem {
                text: qsTr("Reports")
                onClicked: pageStack.animatorPush(Qt.resolvedUrl("Reports.qml"))
            }
        }

        Column {
            id: devicesInfoColumn

            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }

            PageHeader {
                title: qsTr("Devices")
            }

            ComboBox {
                id: deviceSelection

                label: qsTr("Device")
                property ListModel items: ListModel {}
                property var selectedDevice

                onCurrentIndexChanged: {
                    map.center = QtPositioning.coordinate(items.get(currentIndex).position.latitude, items.get(currentIndex).position.longitude)
                    app.coverSelectedDevice = selectedDevice = getDevice(items.get(currentIndex).deviceId)
                }

                menu: ContextMenu {
                    Repeater {
                        model: deviceSelection.items
                        MenuItem {
                           text: name
                       }
                    }
                }
            }

            Column {
                id: paramsColumn
                x: Theme.horizontalPageMargin
                width: parent.width - Theme.horizontalPageMargin*2
                spacing: Theme.paddingSmall

                DeviceProperty {
                    width: parent.width
                    name: qsTr("Name:")
                    value: deviceSelection.selectedDevice.name
                }

                DeviceProperty {
                    width: parent.width
                    name: qsTr("Status:")
                    value: deviceSelection.selectedDevice.status
                }

                DeviceProperty {
                    width: parent.width
                    name: qsTr("Last update:")
                    value: HumanizedTimeSpan.humanized_time_span(new Date(deviceSelection.selectedDevice.lastUpdate))
                }

                DeviceProperty {
                    width: parent.width
                    name: qsTr("Phone:")
                    value: deviceSelection.selectedDevice.phone
                }

                DeviceProperty {
                    width: parent.width
                    name: qsTr("Model:")
                    value: deviceSelection.selectedDevice.model
                }

                DeviceProperty {
                    width: parent.width
                    name: qsTr("Category:")
                    value: deviceSelection.selectedDevice.category
                }
            }
        }

        MapboxMap {
            id: map
            anchors {
                top: devicesInfoColumn.bottom
                topMargin: Theme.paddingLarge
                bottom: parent.bottom
                left: parent.left
                right: parent.right
            }

            center: QtPositioning.coordinate(59.436962, 24.753574)
            zoomLevel: 12.0
            metersPerPixelTolerance: 0.1
            minimumZoomLevel: 0
            maximumZoomLevel: 20
            pixelRatio: Theme.pixelRatio * 1.5

            cacheDatabaseStoreSettings: true
            cacheDatabasePath: ":memory:"

            Behavior on center {
                CoordinateAnimation {
                    duration: 500
                    easing.type: Easing.InOutQuad
                }
            }

            Behavior on margins {
                PropertyAnimation {
                    duration:500
                    easing.type: Easing.InOutQuad
                }
            }

            accessToken: "pk.eyJ1IjoibWlzdGVyLW1hZ2lzdGVyIiwiYSI6ImNrdG1kM2xhMTI0YmkydXBldzFuNjdkZTIifQ.IQx3FyHbkgYmcWpPiJnDow"

            styleUrl: "mapbox://styles/mapbox/outdoors-v10"

            MapboxMapGestureArea {
                id: mouseArea
                map: map
            }

            onStyleJsonChanged: {
                var ns = styleJson.replace("{name_en}", "{name}")
                styleJson = ns;
            }

            Component.onCompleted: {
                var params = {
                    "type": "circle",
                    "source": "points"
                };

                map.addLayer("points-centers", params)
                map.setPaintProperty("points-centers", "circle-radius", 5)
                map.setPaintProperty("points-centers", "circle-color", "black")

                map.addLayer("points-label", {"type": "symbol", "source": "points"})
                map.setLayoutProperty("points-label", "text-field", "{name}")
                map.setLayoutProperty("points-label", "text-justify", "left")
                map.setLayoutProperty("points-label", "text-anchor", "top-left")
                map.setLayoutPropertyList("points-label", "text-offset", [0.2, 0.2])
                map.setPaintProperty("points-label", "text-halo-color", "white")
                map.setPaintProperty("points-label", "text-halo-width", 2)
            }

            function updatePositions() {
                var parsedPositions = JSON.parse(apiClient.positions)
                var points = [];
                var pointNames = [];
                for (var i = 0, position = parsedPositions[i]; i < parsedPositions.length; i++, position = parsedPositions[i]) {
                    var name = tryDeviceName(position.deviceId);
                    points.push(QtPositioning.coordinate(position.latitude, position.longitude));
                    pointNames.push(name);
                    deviceSelection.items.clear()
                    deviceSelection.items.append({name: name, deviceId: position.deviceId, position: position})
                }

                app.coverSelectedDevice = deviceSelection.selectedDevice = getDevice(deviceSelection.items.get(0).deviceId)
                map.updateSourcePoints("points", points, pointNames)
            }

            function tryDeviceName(deviceId) {
                var parsedDevices = JSON.parse(apiClient.devices)
                for (var i = 0, device = parsedDevices[i]; i < parsedDevices.length; i++, device = parsedDevices[i]) {
                    if (device.id === deviceId) return device.name;
                }
                return deviceId;
            }

            function getDevice(deviceId) {
                var parsedDevices = JSON.parse(apiClient.devices)
                for (var i = 0, device = parsedDevices[i]; i < parsedDevices.length; i++, device = parsedDevices[i]) {
                    if (device.id === deviceId) return device;
                }
            }
        }
    }
}
