TARGET = Septitrac

QT += xml widgets

CONFIG += sailfishapp location

SOURCES += src/Septitrac.cpp \
    src/apiclient.cpp \
    src/simplecrypt.cpp

DISTFILES += qml/Septitrac.qml \
    qml/cover/CoverPage.qml \
    qml/js/map_utils.js \
    qml/js/reports_utils.js \
    qml/pages/About.qml \
    qml/pages/Main.qml \
    qml/pages/Settings.qml \
    qml/pages/Reports.qml \
    qml/pages/components/DeviceProperty.qml \
    qml/resources/icons/triangle.png \
    js/humanized_time_span.js \
    rpm/Septitrac.spec \
    translations/*.ts \
    Septitrac.desktop

SAILFISHAPP_ICONS = 86x86 108x108 128x128 172x172

CONFIG += sailfishapp_i18n

TRANSLATIONS += translations/Septitrac-es.ts

HEADERS += \
    src/apiclient.h \
    src/simplecrypt.h

icons.files = qml/resources/icons/triangle.png
icons.path = /usr/share/Septitrac/qml/resources/icons/
