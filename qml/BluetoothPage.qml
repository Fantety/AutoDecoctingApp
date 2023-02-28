import QtQuick 2.15
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.3
import com.qt.bluetoothsearch 1.0

Item {
    anchors.topMargin: 100;

    signal on_search_blue_tooth_button_clicked()
    Rectangle{
        id: bluetooth_page_rectangle;
        Column{
            id: bluetooth_page_colume;
            anchors.centerIn: parent;
            anchors.topMargin: 100;
            Row{
                id: bluetooth_page_row;

                Label{
                    id: open_bluetooth_label;
                    anchors.verticalCenter:parent.verticalCenter;
                    text:"开启蓝牙";
                    color:"white";
                }

                RadioButton{
                    id: search_blue_tooth_button;
                    anchors.verticalCenter:parent.verticalCenter;
                    width: 120;
                    height: 45;
                    Material.background: Material.Green;
                    onClicked: {
                        console.log("开始搜索蓝牙设备");
                        on_search_blue_tooth_button_clicked();
                    }
                }
            }


        }
    }
    BluetoothSearch{
        id: blue_tooth_search;
    }

    Component.onCompleted: {
        on_search_blue_tooth_button_clicked.connect(blue_tooth_search.startDeviceDiscovered)
    }
}
