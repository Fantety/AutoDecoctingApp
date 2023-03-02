import QtQuick 2.15
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.3
import com.qt.bluetoothsearch 1.0

Item {
    anchors.topMargin: 100;
    signal on_search_blue_tooth_button_clicked()
    RoundButton{
        id : round_button;
        width:200;
        radius: 10;
        anchors.horizontalCenter: parent.horizontalCenter;
        text: "开启蓝牙配对";
        height: 50;
        font.pixelSize: 16;
        onClicked: {
            on_search_blue_tooth_button_clicked();
            text = "正在搜索煎药机设备...";
            enabled = false;
        }
    }

    BluetoothSearch{
        id: blue_tooth_search;
    }
    function onSearchFinished(){
        enabled = true;
        text= "开启蓝牙配对";
    }
    function onChangeBtnText(text){
        round_button.text = text;
    }

    Component.onCompleted: {
        on_search_blue_tooth_button_clicked.connect(blue_tooth_search.startDeviceDiscovered);
        blue_tooth_search.searchFinished.connect(onSearchFinished);
        blue_tooth_search.changeBtnText.connect(onChangeBtnText);
    }
}
