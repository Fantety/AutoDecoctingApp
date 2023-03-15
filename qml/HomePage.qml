import QtQuick 2.15
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.3

Rectangle{
    signal startDecocting();
    signal pauseDecocting();
    signal quitDecocting();
    signal settingDecocting();
    Column{
        id: home_page_colume;
        anchors.centerIn: parent;
        RoundButton{
            id: start_button;
            width: 200;
            height: 50;
            radius: 10;
            text: "开始煎药";
            font.pixelSize: 16;
            Material.background: Material.Green;
            onClicked: {
                startDecocting();
            }

        }
        RoundButton{
            id: pause_button;
            width: 200;
            height: 50;
            radius: 10;
            text: "暂停煎药";
            font.pixelSize: 16;
            Material.background: Material.Blue;
            onClicked: {
                pauseDecocting();
            }

        }
        RoundButton{
            id: quit_button;
            width: 200;
            height: 50;
            radius: 10;
            text: "结束煎药";
            font.pixelSize: 16;
            Material.background: Material.Red;
            onClicked: {
                quitDecocting();
            }

        }
        RoundButton{
            id: setting_button;
            width: 200;
            height: 50;
            radius: 10;
            text: "参数设置";
            font.pixelSize: 16;
            Material.background: Material.Purple;
            onClicked: {
                settingDecocting();
            }

        }
    }


}
