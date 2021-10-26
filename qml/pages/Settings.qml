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
import com.verdanditeam.qmlcomponents 1.0
import org.nemomobile.configuration 1.0
import org.nemomobile.systemsettings 1.0

Page {
    id: settingsPage

    AboutSettings { id: aboutSettings }

    SimpleCrypt {
        id: simpleCrypt
        Component.onCompleted: {
            var arr = aboutSettings.wlanMacAddress.replace(':', '').split('');
            arr.forEach(function(part, index) {
                this[index] = part.charCodeAt(0);
            }, arr);
            simpleCrypt.setKey(parseInt(arr.join('')))
        }
    }

    Timer {
        id: hideConnected
        interval: 3000;
        repeat: false
        onTriggered: connectedMessage.visible = false
    }

    ConfigurationGroup {
        id: settings
        path: "/apps/septitrac"

        property string server: ""
        property string login: ""
        property string password: ""
    }

    SilicaFlickable {
        anchors.fill: parent
        flickableDirection: Flickable.VerticalFlick
        contentHeight: column.height + header.height

        PageHeader {
            id: header
            title: qsTr("Settings")
        }

        Column {
            id: column
            spacing: Theme.paddingLarge
            anchors.topMargin: header.height
            anchors.fill: parent

            TextField {
                id: serverValue
                text: settings.server
                label: qsTr("Server")
                labelVisible: true
                placeholderText: label
                width: parent.width
                EnterKey.onClicked: {
                    settings.server = serverValue.text
                    loginValue.focus = true
                }
                onFocusChanged: settings.server = serverValue.text
            }

            TextField {
                id: loginValue
                text: settings.login
                label: qsTr("Login")
                labelVisible: true
                placeholderText: label
                width: parent.width
                EnterKey.onClicked: {
                    settings.login = loginValue.text
                    passwordValue.focus = true
                }
                onFocusChanged: settings.login = loginValue.text
            }

            PasswordField {
                id: passwordValue
                width: parent.width
                label: qsTr("Password")
                labelVisible: true
                placeholderText: label
                EnterKey.onClicked: {
                    settings.password = simpleCrypt.encryptToString(passwordValue.text)
                    passwordValue.focus = false
                }
                onFocusChanged: settings.password = simpleCrypt.encryptToString(passwordValue.text)
            }

            Button {
                text: qsTr("Connect")
//                onClicked: tryLogIn();
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Label {
                id: connectedMessage
                visible: false
                text: qsTr("Connected!")
                anchors.horizontalCenter: parent.horizontalCenter
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeSmall
            }

        }
        VerticalScrollDecorator {}
    }
}
