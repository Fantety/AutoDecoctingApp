#ifndef BLUETOOTHSEARCH_H
#define BLUETOOTHSEARCH_H

#include <QObject>
#include "bleinterface.h"

class BluetoothSearch : public QObject
{
    Q_OBJECT
    BLEInterface *bleInterface;
    void dataReceived(QByteArray data);

public:

    explicit BluetoothSearch(QObject *parent = nullptr);


    void connectToESP();

signals:
    void searchFinished();
    void changeBtnText(QString text);
    void sendDeviceList(QString list);
    void sendServiceList(QString list);
    void sendInfoTerminal(QString msg);
public slots:
    void startScan();
    void startDeviceConnect(int idx);
    void onConnectToService(int idx);
    void onStartDecocting();
    void onPauseDecocting();
    void onQuitDecocting();
};

#endif // BLUETOOTHSEARCH_H
