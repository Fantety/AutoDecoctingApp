#include "BluetoothSearch.h"



BluetoothSearch::BluetoothSearch(QObject *parent)
    : QObject{parent}
{
    bleInterface = new BLEInterface(this);
    connect(bleInterface, SIGNAL(dataReceived(QByteArray)),this, SLOT(dataReceived(QByteArray)));
    connect(bleInterface, &BLEInterface::devicesNamesChanged,
                [this] (QStringList devices){
            for(auto i :devices){
                emit sendDeviceList(i);
                qDebug()<<"device:"<<i;
                emit sendInfoTerminal("搜索到设备: "+i);
                emit searchFinished();
            }
        });
    connect(bleInterface, &BLEInterface::servicesChanged,
            [this] (QStringList services){
            qDebug()<<services.size();
            for(auto i :services){
                emit sendServiceList(i);
                qDebug()<<"service:"<<i;
                emit sendInfoTerminal("服务: "+i);
            }
        });
    //bleInterface->scanDevices();
}

void BluetoothSearch::dataReceived(QByteArray data)
{
    emit sendTemp(data);
    qDebug()<<"xxxxxx";
}

void BluetoothSearch::startScan()
{
     bleInterface->scanDevices();
     emit sendInfoTerminal("正在搜索设备...");
}

void BluetoothSearch::connectToESP()
{
    bleInterface->setCurrentService(0);
    bleInterface->set_currentDevice(0);
    bleInterface->connectCurrentDevice();
}

void BluetoothSearch::startDeviceConnect(int idx)
{
    bleInterface->set_currentDevice(idx);
    qDebug()<<"currentIdx:"<<idx;
    emit sendInfoTerminal("连接至设备: "+QString::number(idx));
    bleInterface->connectCurrentDevice();
}

void BluetoothSearch::onConnectToService(int idx)
{
    bleInterface->setCurrentService(idx);
    emit sendInfoTerminal("连接至服务: "+QString::number(idx));
}


void BluetoothSearch::onStartDecocting()
{
    qDebug()<<"开始煎药";
    QByteArray data;
    data =  QByteArray(QString("start").toLatin1());
    bleInterface->write(data);
}

void BluetoothSearch::onPauseDecocting()
{
    qDebug()<<"开始煎药";
    QByteArray data;
    data =  QByteArray(QString("pause").toLatin1());
    bleInterface->write(data);

}

void BluetoothSearch::onQuitDecocting()
{
    qDebug()<<"开始煎药";
    QByteArray data;
    data =  QByteArray(QString("quit").toLatin1());
    bleInterface->write(data);

}

