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

#ifndef APICLIENT_H
#define APICLIENT_H

#include <QObject>
#include <QUrl>
#include <QTimer>
#include <QNetworkAccessManager>
#include <QQuickItem>
#include "simplecrypt.h"

class ApiClient : public QObject
{
    Q_OBJECT
    Q_PROPERTY(SimpleCrypt* simpleCrypt READ getSimpleCrypt WRITE setSimpleCrypt)
    Q_PROPERTY(QString login READ getLogin WRITE setLogin NOTIFY loginChanged)
    Q_PROPERTY(QString password READ getPassword WRITE setPassword NOTIFY passwordChanged)
    Q_PROPERTY(QString server READ getServer WRITE setServer NOTIFY serverChanged)
    Q_PROPERTY(QString positions READ getPositions NOTIFY positionsChanged)
    Q_PROPERTY(QString devices READ getDevices NOTIFY devicesChanged)
    Q_PROPERTY(QString groups READ getGroups NOTIFY groupsChanged)
    Q_PROPERTY(QString report READ getReport NOTIFY reportChanged)
    Q_PROPERTY(QString trips READ getTrips NOTIFY tripsChanged)
    Q_PROPERTY(QString stops READ getStops NOTIFY stopsChanged)
    Q_PROPERTY(QString summary READ getSummary NOTIFY summaryChanged)
public:
    explicit ApiClient(QObject *parent = nullptr);

    SimpleCrypt* getSimpleCrypt() const;
    void setSimpleCrypt(SimpleCrypt* simpleCrypt);

    QString getLogin() const;
    void setLogin(QString login);
    QString getPassword() const;
    void setPassword(QString password);
    QString getServer() const;
    void setServer(QString server);
    QString getPositions() const;
    void setPositions(QString positions);
    QString getDevices() const;
    void setDevices(QString devices);
    QString getGroups() const;
    void setGroups(QString groups);
    QString getReport() const;
    void setReport(QString report);
    QString getTrips() const;
    void setTrips(QString trips);
    QString getStops() const;
    void setStops(QString stops);
    QString getSummary() const;
    void setSummary(QString summary);

    Q_INVOKABLE void fetchGroups();
    Q_INVOKABLE void fetchRoute(QList<int> devices, QList<int> groups, int period);
    Q_INVOKABLE void fetchRoute(QList<int> devices, QList<int> groups, QString from, QString to);
    Q_INVOKABLE void fetchTrips(QList<int> devices, QList<int> groups, int period);
    Q_INVOKABLE void fetchStops(QList<int> devices, QList<int> groups, int period);
    Q_INVOKABLE void fetchSummary(QList<int> devices, QList<int> groups, int period);
    Q_INVOKABLE void saveAsGpx(QString report);
    Q_INVOKABLE QString getSaveImagePath();

signals:
    void loginChanged();
    void passwordChanged();
    void serverChanged();
    void positionsChanged();
    void devicesChanged();
    void groupsChanged();
    void reportChanged();
    void tripsChanged();
    void stopsChanged();
    void summaryChanged();

private:
    SimpleCrypt* _simpleCrypt;
    QNetworkAccessManager _manager;
    QTimer _updateTimer;
    QString _login, _password, _server;
    QString _positions, _devices, _groups, _report, _trips, _stops, _summary;

    QNetworkReply* getRequest(QUrl url);
    QNetworkReply* postRequest(QUrl url, QString data);
    QByteArray getBasicAuthHeader();
    void fetchData();
    QString implodeList(QList<int> list);
    QDate getDateFrom(int period);
    QDate getDateTo(int period);

};

#endif // APICLIENT_H
