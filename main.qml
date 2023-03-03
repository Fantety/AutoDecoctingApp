import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.VirtualKeyboard 2.15
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.3
import com.qt.bluetoothsearch 1.0

import "./qml"

Window {
    Material.theme: Material.Blue;
    id : main;
    color : "#21373d";
    visible : true;
    width : (Qt.platform.os === "ios" || Qt.platform.os === "android") ? Screen.width : 320;
    height : (Qt.platform.os === "ios" || Qt.platform.os === "android") ? Screen.height : 480;
    property bool isphone : Screen.width < Screen.height ? 1 : 0
    property real multiplierH : main.height / 480;
    property real multiplierW : main.width / 320;
    function dpH(numbers)
    {
        return numbers * multiplierH;
    }
    function dpW(numbers)
    {

        return numbers * multiplierW;
    }
    function dpX(numbers)
    {
        return (dpW(numbers) + dpH(numbers)) / 2;
    }
    Column{
        id: main_column;
        anchors.centerIn: parent;
        anchors.fill: parent;

        MachineInfo{
            id: machine_info;
        }
        Item {
            id: bluetooth_page;
            anchors.left: parent.left;
            anchors.right: parent.right;
            anchors.top:machine_info.bottom;
            anchors.horizontalCenter: parent.horizontalCenter;
            anchors.topMargin: -10;
            signal on_search_blue_tooth_button_clicked(int idx);
            signal connect_to_service(int idx);
            signal start_search();
            Row{
                id: up_row;
                spacing:10;
                anchors.top:bluetooth_page.bottom;
                anchors.horizontalCenter: parent.horizontalCenter;
                RoundButton{
                    id : search_button;
                    width:100;
                    radius: 10;
                    text: "搜索设备";
                    height: 50;
                    font.pixelSize: 16;
                    onClicked: {
                        bluetooth_page.start_search()
                        text = "正在搜索";
                    }
                }
                RoundButton{
                    id : round_button;
                    width:100;
                    radius: 10;
                    text: "连接设备";
                    height: 50;
                    font.pixelSize: 16;
                    onClicked: {
                        bluetooth_page.on_search_blue_tooth_button_clicked(combod.currentIndex);
                    }
                }
                RoundButton{
                    id : round_button_service;
                    width:100;
                    radius: 10;
                    text: "连接服务";
                    height: 50;
                    font.pixelSize: 16;
                    onClicked: {
                        bluetooth_page.connect_to_service(combos.currentIndex);
                    }
                }
            }
            Rectangle{
                id: info_rect;
                color:"black";
                height: 30;
                anchors.left: parent.left;
                anchors.right: parent.right;
                anchors.top:bluetooth_page.bottom;
                anchors.horizontalCenter: parent.horizontalCenter;
                anchors.topMargin: 60;
                Text{
                    id: info_terminal;
                    anchors.horizontalCenter: parent.horizontalCenter;
                    anchors.verticalCenter: parent.verticalCenter;
                    text: "msg";
                    font.pixelSize: 16;
                    color: "white";
                }
                function set_info_terminal_msg(msg){
                    info_terminal.text = msg;
                }
            }


            BluetoothSearch{
                id: blue_tooth_search;
            }
            function onSearchFinished(){
                search_button.text = "搜索设备";
                combod.currentIndex = 0;
            }
            function onChangeBtnText(text){
                round_button.text = text;
            }

            Component.onCompleted: {
                bluetooth_page.on_search_blue_tooth_button_clicked.connect(blue_tooth_search.startDeviceConnect);
                bluetooth_page.connect_to_service.connect(blue_tooth_search.onConnectToService);
                bluetooth_page.start_search.connect(blue_tooth_search.startScan);
                blue_tooth_search.searchFinished.connect(onSearchFinished);
                blue_tooth_search.changeBtnText.connect(onChangeBtnText);
                blue_tooth_search.sendInfoTerminal.connect(info_rect.set_info_terminal_msg)

            }
        }
        Row{
            id:combo_row;
            anchors.top: bluetooth_page.bottom;
            anchors.topMargin: 100;
            anchors.horizontalCenter: parent.horizontalCenter;
            spacing: 10;
            ComboBox{
                id: combod;
                model: ListModel {
                    id: modeld
                }
                function addDeviceItem(str){
                    modeld.append({text: str});
                }
            }
            ComboBox{
                id: combos;
                model: ListModel {
                    id: models
                }
                function addServiceItem(str){
                    models.append({text: str});
                }
            }
            Component.onCompleted: {
                blue_tooth_search.sendDeviceList.connect(combod.addDeviceItem);
                blue_tooth_search.sendServiceList.connect(combos.addServiceItem);
            }
        }

        HomePage{
            id: home_page;
            anchors.left: parent.left;
            anchors.right: parent.right;
            anchors.top:combo_row.bottom;
            anchors.topMargin: 80;
            anchors.horizontalCenter: parent.horizontalCenter;
            Component.onCompleted: {
                startDecocting.connect(blue_tooth_search.onStartDecocting);
                pauseDecocting.connect(blue_tooth_search.onPauseDecocting);
                quitDecocting.connect(blue_tooth_search.onQuitDecocting);
            }
        }
    }

}
