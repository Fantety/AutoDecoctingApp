#include "BluetoothSearch.h"

BluetoothSearch::BluetoothSearch(QObject *parent)
    : QObject{parent}
{
    discoveryAgent = new QBluetoothDeviceDiscoveryAgent();
    localDevice = new QBluetoothLocalDevice();
    connect(discoveryAgent, SIGNAL(deviceDiscovered(QBluetoothDeviceInfo)),this, SLOT(onDeviceDiscovered(QBluetoothDeviceInfo)));
    connect(discoveryAgent,&QBluetoothDeviceDiscoveryAgent::errorOccurred,[=](QBluetoothDeviceDiscoveryAgent::Error error){
            qDebug() << error;
        });
    connect(discoveryAgent,&QBluetoothDeviceDiscoveryAgent::finished,[=](){
            qDebug() << "搜索完成";
        });
}

void BluetoothSearch::onDeviceDiscovered(const QBluetoothDeviceInfo &info)
{
    qDebug() << info.address().toString()<<":"<<info.name();
}

void BluetoothSearch::startDeviceDiscovered()
{
    qDebug() << "开始搜索";
    if( localDevice->hostMode() == QBluetoothLocalDevice::HostPoweredOff)
    {
        localDevice->powerOn();
    }
    discoveryAgent->start();
}
