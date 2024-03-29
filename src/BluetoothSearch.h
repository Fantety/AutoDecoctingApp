﻿#ifndef BLUETOOTHSEARCH_H
#define BLUETOOTHSEARCH_H

#include <QObject>
#include "bleinterface.h"

class BluetoothSearch : public QObject
{
    Q_OBJECT
    BLEInterface *bleInterface;
    int qTime = 0;

    int totalTime = 106*60;
    //20+30+15+10+15+15+1

public:

    explicit BluetoothSearch(QObject *parent = nullptr);

    QString secondToTime(int second){
        int H = second / (60*60);
        int M = (second- (H * 60 * 60)) / 60;
        int S = (second - (H * 60 * 60)) - M * 60;
        QString hour = QString::number(H);
        if (hour.length() == 1) hour = "0" + hour;
        QString min = QString::number(M);
        if (min.length() == 1) min = "0" + min;
        QString sec = QString::number(S);
        if (sec.length() == 1) sec = "0" + sec;
        QString qTime = hour + ":" + min + ":" + sec;
        return qTime;
    };


    void connectToESP();

signals:
    void searchFinished();
    void changeBtnText(QString text);
    void sendDeviceList(QString list);
    void sendServiceList(QString list);
    void sendInfoTerminal(QString msg);
    void sendTemp(QString temp);
    void sendTime(QString time);
    void sendSurplusTime(QString time);
    void sendClearDeviceItem();
    void changeRoundButtonText(QString text);
public slots:
    void startScan();
    void startDeviceConnect(int idx);
    void onConnectToService(int idx);
    void onStartDecocting();
    void onPauseDecocting();
    void onQuitDecocting();
    void dataReceived(QByteArray data);
    void onSaveParam(int soak_time, int constant_temp,int constant_time, int concentration_time, int stepper_value);
    void onDeviceDisconnected(QString info, bool isGood);
};

#endif // BLUETOOTHSEARCH_H
