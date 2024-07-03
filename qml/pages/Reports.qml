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
import Nemo.Notifications 1.0
import "./components"
import "../js/map_utils.js" as MapUtils
import "../js/reports_utils.js" as ReportsUtils

Page {
    id: page

    allowedOrientations: Orientation.All

    SilicaFlickable {
        id: flickable
        anchors.fill: parent

        PullDownMenu {
            MenuItem {
                text: qsTr("Configure")
                onClicked: {
                    for (var i = 0; i < map.pointsCount; i++) {
                        map.removeLayer("points-centers-"+i)
                        map.removeSource("point-"+i)
                    }
                    map.removeLayer("routeCase")
                    map.removeLayer("route")
                    map.removeSource("route")
                    map.selectedTrip = map.selectedStop = map.selectedSummary = undefined
                    pageStack.animatorPush(configureDialogComponent)
                }
            }

            MenuItem {
                text: qsTr("Save route as gpx")
                visible: map.currentRoute !== "" && map.currentRoute !== null
                onClicked: {
                    apiClient.saveAsGpx(map.currentRoute)
                    saveNotification.publish()
                }
            }

            MenuItem {
                text: qsTr("Save route as image")
                visible: map.currentRoute !== "" && map.currentRoute !== null
                onClicked: {
                    saveNotification.publish()
                    map.grabToImage(function(result) {
                        result.saveToFile(apiClient.getSaveImagePath());
                    });
                }
            }
        }

        Notification {
            id: saveNotification
            appName: "Septitrac"
            appIcon: "/usr/share/icons/hicolor/172x172/apps/Septitrac.png"
            summary: "Saved to Documents"
        }

        PageHeader {
            id: header
            title: qsTr("Reports")
        }

        function tryDeviceName(deviceId) {
            var parsedDevices = JSON.parse(apiClient.devices)
            for (var i = 0, device = parsedDevices[i]; i < parsedDevices.length; i++, device = parsedDevices[i]) {
                if (device.id === deviceId) return device.name;
            }
            return deviceId;
        }

        function delay(delayTime, cb) {
            var timer = Qt.createQmlObject("import QtQuick 2.0; Timer {}", root);
            timer.interval = delayTime;
            timer.repeat = false;
            timer.triggered.connect(cb);
            timer.start();
        }

        ExpandingSection {
            id: infoSection
            anchors {
                top: header.bottom
                left: parent.left
                right: parent.right
            }
            title: qsTr("Properties")
            buttonHeight: map.selectedTrip !== undefined || map.selectedStop !== undefined || map.selectedSummary !== undefined ? Theme.itemSizeMedium : 0

            content.sourceComponent: Column {
                x: Theme.horizontalPageMargin
                width: parent.width - Theme.horizontalPageMargin*2
                spacing: Theme.paddingSmall
                height: implicitHeight + Theme.paddingLarge

                Repeater {
                    id: repeater

                    function contains(val) {
                        if (map.selectedTrip !== undefined) return tripValues(val)
                        if (map.selectedStop !== undefined) return stopValues(val)
                        if (map.selectedSummary !== undefined) return summaryValues(val)
                        return false;
                    }

                    function tripValues(val) {
                        switch (val) {
                        case "deviceName":
                        case "maxSpeed":
                        case "averageSpeed":
                        case "distance":
                        case "spentFuel":
                        case "duration":
                        case "startTime":
                        case "endTime":
                        case "driverName":
                            return true;
                        default:
                            return false;
                        }
                    }

                    function stopValues(val) {
                        switch (val) {
                        case "deviceName":
                        case "spentFuel":
                        case "duration":
                        case "startTime":
                        case "endTime":
                        case "driverName":
                        case "engineHours":
                            return true;
                        default:
                            return false;
                        }
                    }

                    function summaryValues(val) {
                        switch (val) {
                        case "deviceName":
                        case "driverName":
                        case "maxSpeed":
                        case "averageSpeed":
                        case "distance":
                        case "spentFuel":
                        case "engineHours":
                            return true;
                        default:
                            return false;
                        }
                    }

                    function getLabel(key) {
                        switch (key) {
                        case "deviceName":
                            return qsTr("Device:")
                        case "maxSpeed":
                            return qsTr("Max speed:")
                        case "averageSpeed":
                            return qsTr("Average Speed:")
                        case "distance":
                            return qsTr("Distance:")
                        case "spentFuel":
                            return qsTr("Spent fuel:")
                        case "duration":
                            return qsTr("Duration:")
                        case "startTime":
                            return qsTr("Start:")
                        case "endTime":
                            return qsTr("End:")
                        case "driverName":
                            return qsTr("Driver:")
                        case "engineHours":
                            return qsTr("Engine hours:")
                        }
                    }

                    function getValue(val) {
                        var value = undefined;
                        if (map.selectedTrip !== undefined) value = map.selectedTrip[val];
                        else if (map.selectedStop !== undefined) value = map.selectedStop[val];
                        else if (map.selectedSummary !== undefined) value = map.selectedSummary[val];
                        switch (val) {
                        case "maxSpeed":
                        case "averageSpeed":
                            return qsTr("%1 km/h").arg(Math.round(value*1.852*10)/10)
                        case "distance":
                            return qsTr("%1 km").arg(Math.round(value/10)/100)
                        case "spentFuel":
                            return qsTr("%1l").arg(value)
                        case "duration":
                        case "engineHours":
                            return ReportsUtils.formatDuration(value/1000)
                        case "startTime":
                        case "endTime":
                            return Qt.formatDateTime(new Date(value), "yyyy-MM-dd HH:mm")
                        case "driverName":
                        default:
                            return value;
                        }
                    }

                    model: ["driverName", "deviceName", "startTime", "endTime", "distance", "maxSpeed", "averageSpeed", "duration", "spentFuel", "engineHours"].filter(function (e) { return contains(e) })
                    DeviceProperty {
                        width: parent.width
                        name: repeater.getLabel(modelData)
                        value: repeater.getValue(modelData)
                    }
                }
            }
        }

        MapboxMap {
            id: map
            anchors {
                top: infoSection.bottom
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }

            center: QtPositioning.coordinate(60.170448, 24.942046)
            zoomLevel: 12.0
            metersPerPixelTolerance: 0.1
            minimumZoomLevel: 0
            maximumZoomLevel: 20
            pixelRatio: Theme.pixelRatio * 1.5

            cacheDatabaseStoreSettings: true
            cacheDatabasePath: ":memory:"

            property var currentRoute: null
            property var selectedTrip
            property var selectedStop
            property var selectedSummary
            property int pointsCount: -1

            Behavior on center {
                CoordinateAnimation {
                    duration: 1000
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

            function displayRoute(report) {
                var data = '{
                        "type": "Feature",
                        "properties": {},
                        "geometry": {
                            "type": "LineString",
                            "coordinates": [';

                for (var i = 0, pos = report[i]; i < report.length; i++, pos = report[i]) {
                    data += "[" + pos.longitude + "," + pos.latitude + "]" + (i < (report.length-1) ? "," : "");
                }
                data += ']
                        }
                    }';

                var routeSource = {
                    "type": "geojson",
                    "data": data
                }

                map.addImagePath("points-triangle", Qt.resolvedUrl("../resources/icons/triangle.png"));

                for (var i = 0; i < pointsCount; i++) {
                    map.removeLayer("points-centers-"+i)
                    map.removeSource("point-"+i)
                }

                pointsCount = report.length;
                for (var i = 1, pos = report[i]; i < report.length; i++, pos = report[i]) {
                    if (i === 1) map.center = QtPositioning.coordinate(pos.latitude, pos.longitude)
                    map.addSourcePoint("point-"+i, QtPositioning.coordinate(pos.latitude, pos.longitude))
                    map.addLayer("points-centers-"+i, {"type": "symbol", "source": "point-"+i})

                    map.setLayoutProperty("points-centers-"+i, "icon-allow-overlap", true);
                    map.setLayoutProperty("points-centers-"+i, "icon-anchor", "top");
                    map.setLayoutProperty("points-centers-"+i, "icon-image", "points-triangle");
                    map.setLayoutProperty("points-centers-"+i, "icon-size", 0.5 / map.pixelRatio);
                    map.setLayoutProperty("points-centers-"+i, "icon-rotate", MapUtils.bearing(report[i-1].longitude, report[i-1].latitude, pos.longitude, pos.latitude));
                }

                map.addSource("route", routeSource)

                map.addLayer("routeCase", { "type": "line", "source": "route" }, "waterway-name")
                map.setLayoutProperty("routeCase", "line-join", "miter");
                map.setLayoutProperty("routeCase", "line-cap", "round");
                map.setPaintProperty("routeCase", "line-color", "white");
                map.setPaintProperty("routeCase", "line-width", 3.0);

                map.addLayer("route", { "type": "line", "source": "route" }, "waterway-name")
                map.setLayoutProperty("route", "line-join", "miter");
                map.setLayoutProperty("route", "line-cap", "round");
                map.setPaintProperty("route", "line-color", "blue");
                map.setPaintProperty("route", "line-width", 2.0);
            }

            onStyleJsonChanged: {
                var ns = styleJson.replace("{name_en}", "{name}")
                styleJson = ns;
            }

            onSelectedTripChanged: {
                apiClient.fetchRoute([map.selectedTrip.deviceId], [], map.selectedTrip.startTime.substring(0, map.selectedTrip.startTime.length-9) + "Z", map.selectedTrip.endTime.substring(0, map.selectedTrip.endTime.length-9) + "Z")
            }

            onSelectedStopChanged: {
                map.center = QtPositioning.coordinate(map.selectedStop.latitude, map.selectedStop.longitude)
                map.addSourcePoint("point-1", QtPositioning.coordinate(map.selectedStop.latitude, map.selectedStop.longitude))
                map.addLayer("points-centers-1", {"type": "circle", "source": "point-1"})

                map.setLayoutProperty("points-centers-1", "circle-radius", 5);
                map.setLayoutProperty("points-centers-1", "circle-color", "blue");
            }

            Connections {
                id: apiClientConnections
                target: apiClient

                onReportChanged: {
                    var report = JSON.parse(apiClient.report)

                    map.currentRoute = apiClient.report

                    map.displayRoute(report)
                }

                onTripsChanged: {
                    var trips = JSON.parse(apiClient.trips).reverse()

                    flickable.delay(500, function () { pageStack.animatorPush(selectTripDialogComponent, {trips: trips}) })
                }

                onStopsChanged: {
                    var stops = JSON.parse(apiClient.stops).reverse()

                    flickable.delay(500, function () { pageStack.animatorPush(selectStopDialogComponent, {stops: stops}) })
                }

                onSummaryChanged: {
                    var summary = JSON.parse(apiClient.summary).reverse()

                    flickable.delay(500, function () { pageStack.animatorPush(selectSummaryDialogComponent, {summary: summary}) })
                }
            }
        }
    }

    Component {
        id: configureDialogComponent

        Dialog {
            id: configureDialog

            onAccepted: {
                map.currentRoute = null
                switch (typeSelector.currentIndex) {
                case 0:
                    apiClient.fetchRoute(deviceSelector.getSelectedDevices(), groupSelector.getSelectedGroups(), periodSelector.currentIndex)
                    break;
                case 1:
                    apiClient.fetchTrips(deviceSelector.getSelectedDevices(), groupSelector.getSelectedGroups(), periodSelector.currentIndex)
                    break;
                case 2:
                    apiClient.fetchStops(deviceSelector.getSelectedDevices(), groupSelector.getSelectedGroups(), periodSelector.currentIndex)
                    break;
                case 3:
                    apiClient.fetchSummary(deviceSelector.getSelectedDevices(), groupSelector.getSelectedGroups(), periodSelector.currentIndex)
                    break;
                }
            }


            DialogHeader {
                id: header
            }

            Column {
                anchors {
                    top: header.bottom
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                }

                ComboBox {
                    id: typeSelector
                    label: qsTr("Type")
                    menu: ContextMenu {
                        MenuItem { text: qsTr("Route") }
                        MenuItem { text: qsTr("Trips") }
                        MenuItem { text: qsTr("Stops") }
                        MenuItem { text: qsTr("Summary") }
                    }
                }

                ExpandingSection {
                    id: deviceSelector
                    title: qsTr("Device")
                    property Repeater repeater

                    function getSelectedDevices() {
                        if (repeater === null) return [];

                        var devices = [];
                        for (var i = 0, device = repeater.itemAt(i); i < repeater.count; i++, device = repeater.itemAt(i)) {
                            if (device.checked) devices.push(device.id)
                        }

                        return devices;
                    }

                    content.sourceComponent: Column {
                        width: parent.width

                        Repeater {
                            id: deviceSelectorRepeater
                            model: JSON.parse(apiClient.devices)
                            Component.onCompleted: deviceSelector.repeater = deviceSelectorRepeater

                            TextSwitch {
                                text: model.modelData.name
                                property int id: model.modelData.id
                            }
                        }
                    }
                }

                ExpandingSection {
                    id: groupSelector
                    title: qsTr("Group")
                    property Repeater repeater


                    function getSelectedGroups() {
                        if (repeater === null) return [];

                        var groups = [];
                        for (var i = 0, group = repeater.itemAt(i); i < repeater.count; i++, group = repeater.itemAt(i)) {
                            if (group.checked) groups.push(group.id)
                        }

                        return groups;
                    }


                    content.sourceComponent: Column {
                        width: parent.width

                        Repeater {
                            id: groupSelectorRepeater
                            model: JSON.parse(apiClient.groups)
                            Component.onCompleted: {
                                apiClient.fetchGroups()
                                groupSelector.repeater = groupSelectorRepeater
                            }

                            TextSwitch {
                                text: model.modelData.name
                                property int id: model.modelData.id
                            }
                        }
                    }
                }

                ComboBox {
                    id: periodSelector
                    label: qsTr("Period")
                    menu: ContextMenu {
                        MenuItem { text: qsTr("Today") }
                        MenuItem { text: qsTr("Yesterday") }
                        MenuItem { text: qsTr("This Week") }
                        MenuItem { text: qsTr("Previous Week") }
                        MenuItem { text: qsTr("This Month") }
                        MenuItem { text: qsTr("Previous Month") }
                    }
                }
            }
        }
    }

    Component {
        id: selectTripDialogComponent

        Dialog {
            id: selectTripDialog
            canAccept: false
            property var trips

            DialogHeader {
                id: header
            }

            SilicaListView {
                anchors {
                    top: header.bottom
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                }

                clip: true
                model: trips
                delegate: ListItem {
                    contentHeight: col.height + Theme.paddingLarge
                    onClicked: {
                        map.selectedTrip = modelData
                        pageStack.pop();
                    }

                    Column {
                        id: col
                        x: Theme.horizontalPageMargin
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - Theme.horizontalPageMargin*2
                        spacing: Theme.paddingSmall

                        Row {
                            width: parent.width

                            DeviceProperty {
                                width: parent.width/2
                                name: qsTr("Device:")
                                value: modelData.deviceName
                            }

                            DeviceProperty {
                                width: parent.width/2
                                name: qsTr("Driver:")
                                value: modelData.driver ? modelData.driver : ""
                            }
                        }

                        Row {
                            width: parent.width

                            DeviceProperty {
                                width: parent.width/2
                                name: qsTr("Start:")
                                value: Qt.formatDateTime(new Date(modelData.startTime),"yy-MM-dd HH:mm")
                            }

                            DeviceProperty {
                                width: parent.width/2
                                name: qsTr("End:")
                                value: Qt.formatDateTime(new Date(modelData.endTime),"yy-MM-dd HH:mm")
                            }
                        }
                    }
                }
            }
        }
    }

    Component {
        id: selectStopDialogComponent

        Dialog {
            id: selectStopDialog
            canAccept: false
            property var stops

            DialogHeader {
                id: header
            }

            SilicaListView {
                anchors {
                    top: header.bottom
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                }

                clip: true
                model: stops
                delegate: ListItem {
                    contentHeight: col.height + Theme.paddingLarge
                    onClicked: {
                        map.selectedStop = modelData
                        pageStack.pop();
                    }

                    Column {
                        id: col
                        x: Theme.horizontalPageMargin
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - Theme.horizontalPageMargin*2
                        spacing: Theme.paddingSmall

                        Row {
                            width: parent.width

                            DeviceProperty {
                                width: parent.width/2
                                name: qsTr("Device:")
                                value: modelData.deviceName
                            }

                            DeviceProperty {
                                width: parent.width/2
                                name: qsTr("Driver:")
                                value: modelData.driver ? modelData.driver : ""
                            }
                        }

                        Row {
                            width: parent.width

                            DeviceProperty {
                                width: parent.width/2
                                name: qsTr("Start:")
                                value: Qt.formatDateTime(new Date(modelData.startTime),"yy-MM-dd HH:mm")
                            }

                            DeviceProperty {
                                width: parent.width/2
                                name: qsTr("End:")
                                value: Qt.formatDateTime(new Date(modelData.endTime),"yy-MM-dd HH:mm")
                            }
                        }
                    }
                }
            }
        }
    }

    Component {
        id: selectSummaryDialogComponent

        Dialog {
            id: selectSummaryDialog
            canAccept: false
            property var summary

            DialogHeader {
                id: header
            }

            SilicaListView {
                anchors {
                    top: header.bottom
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                }

                clip: true
                model: summary
                delegate: ListItem {
                    contentHeight: col.height + Theme.paddingLarge
                    onClicked: {
                        map.selectedSummary = modelData
                        pageStack.pop();
                    }

                    Column {
                        id: col
                        x: Theme.horizontalPageMargin
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - Theme.horizontalPageMargin*2
                        spacing: Theme.paddingSmall

                        Row {
                            width: parent.width

                            DeviceProperty {
                                width: parent.width/2
                                name: qsTr("Device:")
                                value: modelData.deviceName
                            }

                            DeviceProperty {
                                width: parent.width/2
                                name: qsTr("Driver:")
                                value: modelData.driver ? modelData.driver : ""
                            }
                        }
                    }
                }
            }
        }
    }
}
