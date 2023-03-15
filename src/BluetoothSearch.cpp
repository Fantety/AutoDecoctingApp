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
    QString s_data = QString(data);
    QStringList list;
    if(s_data.contains(";")){
        list = s_data.split(";");
        if(list[0].front() == 'c'){
            emit sendTemp(list[0].mid(1));
        }
        //时间刻
        if(list[1].front() == 't'){
            emit sendTime(secondToTime(list[1].mid(1).toInt()));
        }
    }
}

void BluetoothSearch::onSaveParam(int soak_time, int first_temp, int middle_temp)
{
    QByteArray data;
    data =  QByteArray(QString("p"+QString::number(soak_time)+","+QString::number(first_temp)+","+QString::number(middle_temp)).toLatin1());
    bleInterface->write(data);
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

