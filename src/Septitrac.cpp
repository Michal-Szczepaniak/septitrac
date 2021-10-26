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

#include <QtQuick>
#include <sailfishapp.h>
#include "apiclient.h"
#include "simplecrypt.h"

int main(int argc, char *argv[])
{
    QScopedPointer<QGuiApplication> app(SailfishApp::application(argc, argv));
    QSharedPointer<QQuickView> view(SailfishApp::createView());

    qmlRegisterType<ApiClient>("com.verdanditeam.qmlcomponents", 1, 0, "ApiClient");
    qmlRegisterType<SimpleCrypt>("com.verdanditeam.qmlcomponents", 1, 0, "SimpleCrypt");

    view->setSource(SailfishApp::pathTo("qml/Septitrac.qml"));
    view->show();

    return app->exec();
}
