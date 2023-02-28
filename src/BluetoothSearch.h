#ifndef BLUETOOTHSEARCH_H
#define BLUETOOTHSEARCH_H

#include <QObject>
#include <QtBluetooth/QBluetoothDeviceDiscoveryAgent>
#include <QtBluetooth/QBluetoothLocalDevice>
#include <QtBluetooth/QBluetoothDeviceInfo>
class BluetoothSearch : public QObject
{
    Q_OBJECT

    QBluetoothDeviceDiscoveryAgent* discoveryAgent;
    QBluetoothLocalDevice* localDevice;
public:
    explicit BluetoothSearch(QObject *parent = nullptr);

signals:

public slots:
    void onDeviceDiscovered(const QBluetoothDeviceInfo &info);
    void startDeviceDiscovered();
};

#endif // BLUETOOTHSEARCH_H
