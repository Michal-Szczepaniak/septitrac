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
import org.nemomobile.systemsettings 1.0
import org.nemomobile.configuration 1.0
import "pages"

ApplicationWindow {
    id: app
    initialPage: Component { Main { } }
    cover: Qt.resolvedUrl("cover/CoverPage.qml")
    allowedOrientations: defaultAllowedOrientations

    property var coverSelectedDevice


    AboutSettings {
        id: aboutSettings
        onStorageChanged: if (apiClient.simpleCrypt === null) apiClient.simpleCrypt = simpleCrypt
    }

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

    ConfigurationGroup {
        id: settings
        path: "/apps/septitrac"

        property string server: ""
        property string login: ""
        property string password: ""
    }

    ApiClient {
        id: apiClient
        server: settings.server
        login: settings.login
        password: settings.password
    }
}
