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
            anchors.topMargin: -20;
            signal on_connect_blue_tooth_button_clicked(int idx);
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
                        bluetooth_page.start_search();
                        enabled = false;
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
                    property bool status: false
                    onClicked: {
                        if (status == false){
                            bluetooth_page.on_connect_blue_tooth_button_clicked(combod.currentIndex);
                        }
                        else{
                            bluetooth_page.on_connect_blue_tooth_button_clicked(-1);
                            search_button.enabled = true;
                        }
                        status = !status;
                    }
                    function change_round_button_text(text){
                        round_button.text = text;
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
                bluetooth_page.on_connect_blue_tooth_button_clicked.connect(blue_tooth_search.startDeviceConnect);
                bluetooth_page.connect_to_service.connect(blue_tooth_search.onConnectToService);
                bluetooth_page.start_search.connect(blue_tooth_search.startScan);
                blue_tooth_search.searchFinished.connect(onSearchFinished);
                blue_tooth_search.changeBtnText.connect(onChangeBtnText);
                blue_tooth_search.sendInfoTerminal.connect(info_rect.set_info_terminal_msg)
                blue_tooth_search.sendTemp.connect(machine_info.set_temp)
                blue_tooth_search.sendTime.connect(machine_info.set_time)
                blue_tooth_search.sendSurplusTime.connect(machine_info.set_surplus_time)
                blue_tooth_search.changeRoundButtonText.connect(round_button.change_round_button_text)

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
            function clearDeviceData(){
                modeld.clear();
                models.clear();
                round_button.text = "连接设备"
            }

            Component.onCompleted: {
                blue_tooth_search.sendDeviceList.connect(combod.addDeviceItem);
                blue_tooth_search.sendServiceList.connect(combos.addServiceItem);
                blue_tooth_search.sendClearDeviceItem.connect(combo_row.clearDeviceData);
            }
        }

        HomePage{
            id: home_page;
            anchors.left: parent.left;
            anchors.right: parent.right;
            anchors.top:combo_row.bottom;
            anchors.topMargin: 100;
            anchors.horizontalCenter: parent.horizontalCenter;
            Component.onCompleted: {
                startDecocting.connect(blue_tooth_search.onStartDecocting);
                pauseDecocting.connect(blue_tooth_search.onPauseDecocting);
                quitDecocting.connect(blue_tooth_search.onQuitDecocting);
                settingDecocting.connect(setting_page.show_setting);
            }
        }

        Page{
            signal save_param(int soak_time, int constant_temp,int constant_time, int concentration_time, int stepper_value)
            id: setting_page;
            visible: false;
            anchors.fill: parent;
            function show_setting(){
                setting_page.visible = true;
            }
            Component.onCompleted: {
                save_param.connect(blue_tooth_search.onSaveParam);
            }
            Column{
                anchors.fill: parent;
                Row{
                    anchors.horizontalCenter: parent.horizontalCenter;
                    Text{
                        anchors.verticalCenter: parent.verticalCenter;
                        text:"浸泡时间(分钟)";
                        font.pixelSize: 16;
                        color:"white";
                    }
                    Slider{
                        id: soak_time;
                        stepSize: 1;
                        from: 10
                        value: 20
                        to: 60
                        width: 100;
                        onMoved: {
                            soak_time_value.text = soak_time.value.toString();
                        }
                    }
                    Text{
                        id: soak_time_value;
                        anchors.verticalCenter: parent.verticalCenter;
                        text:"20";
                        font.pixelSize: 16;
                        color:"white";
                    }
                }
                Row{
                    anchors.horizontalCenter: parent.horizontalCenter;
                    Text{
                        anchors.verticalCenter: parent.verticalCenter;
                        text:"恒温温度(摄氏)";
                        color:"white";
                        font.pixelSize: 16;
                    }
                    Slider{
                        id: constant_temp;
                        stepSize: 1;
                        from: 70
                        value: 75
                        to: 80
                        width: 100;
                        onMoved: {
                            constant_temp_value.text = constant_temp.value.toString();
                        }
                    }
                    Text{
                        id: constant_temp_value;
                        color:"white";
                        anchors.verticalCenter: parent.verticalCenter;
                        text:"75";
                        font.pixelSize: 16;
                    }
                }
                Row{
                    anchors.horizontalCenter: parent.horizontalCenter;
                    Text{
                        anchors.verticalCenter: parent.verticalCenter;
                        text:"恒温时间(摄氏)";
                        font.pixelSize: 16;
                        color:"white";
                    }
                    Slider{
                        id: constant_time;
                        stepSize: 1;
                        from: 10
                        value: 15
                        to: 60
                        width: 100;
                        onMoved: {
                            constant_time_value.text = constant_time.value.toString();
                        }
                    }
                    Text{
                        id: constant_time_value;
                        anchors.verticalCenter: parent.verticalCenter;
                        text:"15";
                        color:"white";
                        font.pixelSize: 16;
                    }
                }
                Row{
                    anchors.horizontalCenter: parent.horizontalCenter;
                    Text{
                        anchors.verticalCenter: parent.verticalCenter;
                        text:"浓缩时间(分钟)";
                        font.pixelSize: 16;
                        color:"white";
                    }
                    Slider{
                        id: concentration_time;
                        stepSize: 1;
                        from: 10
                        value: 15
                        to: 60
                        width: 100;
                        onMoved: {
                            concentration_time_value.text = concentration_time.value.toString();
                        }
                    }
                    Text{
                        id: concentration_time_value;
                        anchors.verticalCenter: parent.verticalCenter;
                        text:"15";
                        font.pixelSize: 16;
                        color:"white";
                    }
                }
                Row{
                    anchors.horizontalCenter: parent.horizontalCenter;
                    Text{
                        anchors.verticalCenter: parent.verticalCenter;
                        text:"电机步距";
                        font.pixelSize: 16;
                        color:"white";
                    }
                    Slider{
                        id: stepper_value;
                        stepSize: 0.5;
                        from: 0
                        value: 12.5
                        to: 50
                        width: 100;
                        onMoved: {
                            stepper_value_value.text = stepper_value.value.toString();
                        }
                    }
                    Text{
                        id: stepper_value_value;
                        anchors.verticalCenter: parent.verticalCenter;
                        text:"12.5";
                        font.pixelSize: 16;
                        color:"white";
                    }
                }
                RoundButton{
                    anchors.horizontalCenter: parent.horizontalCenter;
                    id: save_button;
                    width: 200;
                    height: 50;
                    radius: 10;
                    text: "保存参数";
                    font.pixelSize: 16;
                    Material.background: Material.Purple;
                    onClicked: {
                        setting_page.save_param(soak_time.value, constant_temp.value, constant_time.value, concentration_time.value, stepper_value.value)
                        setting_page.visible = false;
                    }
                }
                RoundButton{
                    anchors.horizontalCenter: parent.horizontalCenter;
                    id: cancel_button;
                    width: 200;
                    height: 50;
                    radius: 10;
                    text: "取消";
                    font.pixelSize: 16;
                    Material.background: Material.Red;
                    onClicked: {
                        setting_page.visible = false;
                    }
                }
            }
        }
    }

}
