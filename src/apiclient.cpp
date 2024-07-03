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

#include "apiclient.h"
#include <QDebug>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QUrlQuery>
#include <QStringBuilder>
#include <QtXml>
#include <QGraphicsObject>
#include <QPainter>
#include <QStyleOptionGraphicsItem>

ApiClient::ApiClient(QObject *parent) : QObject(parent), _simpleCrypt(nullptr)
{
    connect(&_updateTimer, &QTimer::timeout, [=]() { fetchData(); });
    _updateTimer.start(10000);
}

SimpleCrypt *ApiClient::getSimpleCrypt() const
{
    return _simpleCrypt;
}

void ApiClient::setSimpleCrypt(SimpleCrypt* simpleCrypt)
{
    _simpleCrypt = simpleCrypt;

    fetchData();
}

QString ApiClient::getLogin() const
{
    return _login;
}

void ApiClient::setLogin(QString login)
{
    _login = login;
    emit loginChanged();
}

QString ApiClient::getPassword() const
{
    return _password;
}

void ApiClient::setPassword(QString password)
{
    _password = password;
    emit passwordChanged();
}

QString ApiClient::getServer() const
{
    return _server;
}

void ApiClient::setServer(QString server)
{
    _server = server;
    emit serverChanged();
}

QString ApiClient::getPositions() const
{
    return _positions;
}

void ApiClient::setPositions(QString positions)
{
    _positions = positions;
    emit positionsChanged();
}

QString ApiClient::getDevices() const
{
    return _devices;
}

void ApiClient::setDevices(QString devices)
{
    _devices = devices;
    emit devicesChanged();
}

QString ApiClient::getGroups() const
{
    return _groups;
}

void ApiClient::setGroups(QString groups)
{
    _groups = groups;
    emit groupsChanged();
}

QString ApiClient::getReport() const
{
    return _report;
}

void ApiClient::setReport(QString report)
{
    _report = report;
    emit reportChanged();
}

QString ApiClient::getTrips() const
{
    return _trips;
}

void ApiClient::setTrips(QString trips)
{
    _trips = trips;
    emit tripsChanged();
}

QString ApiClient::getStops() const
{
    return _stops;
}

void ApiClient::setStops(QString stops)
{
    _stops = stops;
    emit stopsChanged();
}

QString ApiClient::getSummary() const
{
    return _summary;
}

void ApiClient::setSummary(QString summary)
{
    _summary = summary;
    emit summaryChanged();
}

void ApiClient::fetchGroups()
{
    QNetworkReply* replay = getRequest(QUrl(_server + "/api/groups"));
    connect(replay, &QNetworkReply::finished, [=]() { setGroups(QString(replay->readAll())); emit replay->deleteLater(); });
    connect(replay, static_cast<void(QNetworkReply::*)(QNetworkReply::NetworkError)>(&QNetworkReply::error), [=](QNetworkReply::NetworkError error) { qDebug() << error; });
}

void ApiClient::fetchRoute(QList<int> devices, QList<int> groups, int period)
{
    fetchRoute(devices, groups, QDateTime(getDateFrom(period)).toString(Qt::ISODate) + "Z", QDateTime(getDateTo(period)).toString(Qt::ISODate) + "Z");
}

void ApiClient::fetchRoute(QList<int> devices, QList<int> groups, QString from, QString to)
{
    QUrl url(_server + "/api/reports/route");
    QUrlQuery q;
    if (!devices.empty()) q.addQueryItem("deviceId", implodeList(devices));
    if (!groups.empty()) q.addQueryItem("groupId", implodeList(groups));

    q.addQueryItem("from", from);
    q.addQueryItem("to", to);

    url.setQuery(q);
    QNetworkReply* replay = getRequest(url);
    connect(replay, &QNetworkReply::finished, [=]() { setReport(QString(replay->readAll())); emit replay->deleteLater(); });
    connect(replay, static_cast<void(QNetworkReply::*)(QNetworkReply::NetworkError)>(&QNetworkReply::error), [=](QNetworkReply::NetworkError error) { qDebug() << error; });
}

void ApiClient::fetchTrips(QList<int> devices, QList<int> groups, int period)
{
    QUrl url(_server + "/api/reports/trips");
    QUrlQuery q;
    if (!devices.empty()) q.addQueryItem("deviceId", implodeList(devices));
    if (!groups.empty()) q.addQueryItem("groupId", implodeList(groups));

    q.addQueryItem("from", QDateTime(getDateFrom(period)).toString(Qt::ISODate) + "Z");
    q.addQueryItem("to", QDateTime(getDateTo(period)).toString(Qt::ISODate) + "Z");

    url.setQuery(q);
    QNetworkReply* replay = getRequest(url);
    connect(replay, &QNetworkReply::finished, [=]() { setTrips(QString(replay->readAll())); emit replay->deleteLater(); });
    connect(replay, static_cast<void(QNetworkReply::*)(QNetworkReply::NetworkError)>(&QNetworkReply::error), [=](QNetworkReply::NetworkError error) { qDebug() << error; });
}

void ApiClient::fetchStops(QList<int> devices, QList<int> groups, int period)
{
    QUrl url(_server + "/api/reports/stops");
    QUrlQuery q;
    if (!devices.empty()) q.addQueryItem("deviceId", implodeList(devices));
    if (!groups.empty()) q.addQueryItem("groupId", implodeList(groups));

    q.addQueryItem("from", QDateTime(getDateFrom(period)).toString(Qt::ISODate) + "Z");
    q.addQueryItem("to", QDateTime(getDateTo(period)).toString(Qt::ISODate) + "Z");

    url.setQuery(q);
    QNetworkReply* replay = getRequest(url);
    connect(replay, &QNetworkReply::finished, [=]() { setStops(QString(replay->readAll())); emit replay->deleteLater(); });
    connect(replay, static_cast<void(QNetworkReply::*)(QNetworkReply::NetworkError)>(&QNetworkReply::error), [=](QNetworkReply::NetworkError error) { qDebug() << error; });
}

void ApiClient::fetchSummary(QList<int> devices, QList<int> groups, int period)
{
    QUrl url(_server + "/api/reports/summary");
    QUrlQuery q;
    if (!devices.empty()) q.addQueryItem("deviceId", implodeList(devices));
    if (!groups.empty()) q.addQueryItem("groupId", implodeList(groups));

    q.addQueryItem("from", QDateTime(getDateFrom(period)).toString(Qt::ISODate) + "Z");
    q.addQueryItem("to", QDateTime(getDateTo(period)).toString(Qt::ISODate) + "Z");

    url.setQuery(q);
    QNetworkReply* replay = getRequest(url);
    connect(replay, &QNetworkReply::finished, [=]() { setSummary(QString(replay->readAll())); emit replay->deleteLater(); });
    connect(replay, static_cast<void(QNetworkReply::*)(QNetworkReply::NetworkError)>(&QNetworkReply::error), [=](QNetworkReply::NetworkError error) { qDebug() << error; });
}

void ApiClient::saveAsGpx(QString report)
{
    QDomDocument doc;
    QDomElement gpx = doc.createElement("gpx");
    gpx.setAttribute("version", "1.0");
    doc.appendChild(gpx);

    QDomElement trk = doc.createElement("trk");
    gpx.appendChild(trk);

    QDomElement name = doc.createElement("name");
    name.appendChild(doc.createTextNode("Septitrac gpx"));
    trk.appendChild(name);

    QDomElement seg = doc.createElement("trkseg");
    trk.appendChild(seg);

    QJsonDocument jdoc = QJsonDocument::fromJson(report.toUtf8());
    for (QJsonValue val : jdoc.array()) {
        QJsonObject obj = val.toObject();

        QDomElement trkpt = doc.createElement("trkpt");
        seg.appendChild(trkpt);

        trkpt.setAttribute("lat", QString::number(obj["latitude"].toDouble()));
        trkpt.setAttribute("lon", QString::number(obj["longitude"].toDouble()));

        QDomElement ele = doc.createElement("ele");
        ele.appendChild(doc.createTextNode(QString::number(obj["altitude"].toDouble())));
        trkpt.appendChild(ele);

        QDomElement time = doc.createElement("time");
        QString timeString = obj["deviceTime"].toString();
        timeString = timeString.split('.').first() + "Z";
        time.appendChild(doc.createTextNode(timeString));
        trkpt.appendChild(time);
    }

    QFile file(QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation) + "/septitrac-" + QDateTime::currentDateTime().toString("yyyy-MM-dd_HH-mm-ss") + ".gpx");
    if (file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        QTextStream stream(&file);
        stream << doc.toString();
        file.close();
    }
}

QString ApiClient::getSaveImagePath()
{
    return QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation) + "/septitrac-" + QDateTime::currentDateTime().toString("yyyy-MM-dd_HH-mm-ss") + ".png";
}

QNetworkReply* ApiClient::getRequest(QUrl url)
{
    QNetworkRequest request(url);
    request.setRawHeader("Authorization", getBasicAuthHeader());
    request.setRawHeader("Accept", "application/json");
    return _manager.get(request);
}

QNetworkReply *ApiClient::postRequest(QUrl url, QString data)
{
    QNetworkRequest request(url);
    request.setRawHeader("Authorization", getBasicAuthHeader());
    request.setRawHeader("Accept", "application/json");
    return _manager.post(request, data.toLocal8Bit());
}

QByteArray ApiClient::getBasicAuthHeader()
{
    QString concatenated = _login + ":" + _simpleCrypt->decryptToString(_password);
    QByteArray data = concatenated.toLocal8Bit().toBase64();
    QString headerData = "Basic " + data;
    return headerData.toLocal8Bit();
}

void ApiClient::fetchData()
{
    QNetworkReply* replay = getRequest(QUrl(_server + "/api/positions"));
    connect(replay, &QNetworkReply::finished, [=]() { setPositions(QString(replay->readAll())); emit replay->deleteLater(); });
    connect(replay, static_cast<void(QNetworkReply::*)(QNetworkReply::NetworkError)>(&QNetworkReply::error), [=](QNetworkReply::NetworkError error) { qDebug() << error; });

    replay = getRequest(QUrl(_server + "/api/devices"));
    connect(replay, &QNetworkReply::finished, [=]() { setDevices(QString(replay->readAll())); emit replay->deleteLater(); });
    connect(replay, static_cast<void(QNetworkReply::*)(QNetworkReply::NetworkError)>(&QNetworkReply::error), [=](QNetworkReply::NetworkError error) { qDebug() << error; });
}

QString ApiClient::implodeList(QList<int> list)
{
    QStringList result;

    for (int element: list) {
        result << QString::number(element);
    }

    return result.join(',');
}

QDate ApiClient::getDateFrom(int period)
{
    QDate current = QDateTime::currentDateTime().date();

    switch (period) {
    case 0:
        return current;
    case 1:
        return current.addDays(-1);
    case 2:
        return current.addDays(-current.dayOfWeek());
    case 3:
        return current.addDays(-current.dayOfWeek()-7);
    case 4:
        return current.addDays(-current.day());
    case 5:
        return current.addDays(-current.day()).addMonths(-1);
    }
}

QDate ApiClient::getDateTo(int period)
{
    QDate current = QDateTime::currentDateTime().date();

    switch (period) {
    case 0:
        return current.addDays(1);
    case 1:
        return current;
    case 2:
        return current.addDays((7-current.dayOfWeek()));
    case 3:
        return current.addDays(-current.dayOfWeek());
    case 4:
        return current.addDays(-current.day()).addMonths(1);
    case 5:
        return current.addDays(-current.day());
    }
}
