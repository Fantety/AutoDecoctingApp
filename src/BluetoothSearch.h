#ifndef BLUETOOTHSEARCH_H
#define BLUETOOTHSEARCH_H

#include <QObject>
#include "bleinterface.h"

class BluetoothSearch : public QObject
{
    Q_OBJECT
    BLEInterface *bleInterface;


public:

    explicit BluetoothSearch(QObject *parent = nullptr);


    void connectToESP();

signals:
    void searchFinished();
    void changeBtnText(QString text);
    void sendDeviceList(QString list);
    void sendServiceList(QString list);
    void sendInfoTerminal(QString msg);
    void sendTemp(QString temp);
public slots:
    void startScan();
    void startDeviceConnect(int idx);
    void onConnectToService(int idx);
    void onStartDecocting();
    void onPauseDecocting();
    void onQuitDecocting();
    void dataReceived(QByteArray data);
};

#endif // BLUETOOTHSEARCH_H
