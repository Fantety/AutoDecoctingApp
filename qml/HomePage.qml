import QtQuick 2.15
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.3

Rectangle{
    Column{
        id: home_page_colume;
        anchors.centerIn: parent;
        RoundButton{
            id: start_button;
            width: 120;
            height: 45;
            text: "开始煎药";
            Material.background: Material.Green;
            onClicked: {
                console.log("hello TaoQuick")
            }

        }
        RoundButton{
            id: pause_button;
            width: 120;
            height: 45;
            text: "暂停煎药";
            Material.background: Material.Blue;
            onClicked: {
                console.log("hello TaoQuick")
            }

        }
        RoundButton{
            id: quit_button;
            width: 120;
            height: 45;
            text: "结束煎药";
            Material.background: Material.Red;
            onClicked: {
                console.log("hello TaoQuick")
            }

        }
    }


}
