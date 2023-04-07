#include "BluetoothSearch.h"



BluetoothSearch::BluetoothSearch(QObject *parent)
    : QObject{parent}
{
    bleInterface = new BLEInterface(this);
    connect(bleInterface, SIGNAL(dataReceived(QByteArray)),this, SLOT(dataReceived(QByteArray)));
    connect(bleInterface, SIGNAL(statusInfoChanged(QString, bool)), this, SLOT(onDeviceDisconnected(QString, bool)));
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
        if(list[1].front() == 't'){
            emit sendTime(secondToTime(list[1].mid(1).toInt()));
        }
        if(list[2].front() == 'l' and list[3].front() == 's'){
            emit sendInfoTerminal("阶段: "+list[2].mid(1)+"/状态: "+list[3].mid(1));
        }
    }
}

void BluetoothSearch::onSaveParam(int soak_time, int constant_temp,int constant_time, int concentration_time, int stepper_value)
{
    QByteArray data;
    //p[浸泡时间],[恒温温度],[恒温时间],[浓缩时间],[电机步距]
    data =  QByteArray(QString("p"+QString::number(soak_time)+","
                               +QString::number(constant_temp)+","
                               +QString::number(constant_time)+","
                               +QString::number(concentration_time)+","
                               +QString::number(stepper_value)).toLatin1());
    bleInterface->write(data);
}

void BluetoothSearch::onDeviceDisconnected(QString info, bool isGood)
{
    if(info == "Service disconnected"){
        emit sendClearDeviceItem();
        emit sendInfoTerminal("连接已断开");
    }

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
    if(idx != -1){
        bleInterface->set_currentDevice(idx);
        qDebug()<<"currentIdx:"<<idx;
        emit sendInfoTerminal("连接至设备: "+QString::number(idx));
        emit changeRoundButtonText("断开连接");
        bleInterface->connectCurrentDevice();
    }
    else if(idx == -1){
        bleInterface->disconnectDevice();
        emit changeRoundButtonText("连接设备");
    }
}

void BluetoothSearch::onConnectToService(int idx)
{
    bleInterface->setCurrentService(idx);
    emit sendInfoTerminal("连接至服务: "+QString::number(idx));
}


void BluetoothSearch::onStartDecocting()
{
    //qDebug()<<"开始煎药";
    QByteArray data;
    data =  QByteArray(QString("start").toLatin1());
    bleInterface->write(data);
}

void BluetoothSearch::onPauseDecocting()
{
    //qDebug()<<"开始煎药";
    QByteArray data;
    data =  QByteArray(QString("pause").toLatin1());
    bleInterface->write(data);

}

void BluetoothSearch::onQuitDecocting()
{
    //qDebug()<<"开始煎药";
    QByteArray data;
    data =  QByteArray(QString("quit").toLatin1());
    bleInterface->write(data);

}

