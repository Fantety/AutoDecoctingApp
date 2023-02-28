import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.VirtualKeyboard 2.15
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.3
import "./qml"

Window {
    Material.theme: Material.Blue;
    id : main;
    color : "white";
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

        SwipeView {
            id: view;
            currentIndex: pageIndicator.currentIndex;
            anchors.fill: parent;

            Page {
                HomePage{
                    anchors.centerIn: parent;
                    id:home_page;
                }
            }
            Page {
                title: qsTr("Discover");
            }
            Page {
                title: qsTr("Activity");
            }
        }

    }



    PageIndicator {
        id: pageIndicator;
        interactive: true;
        count: view.count;
        currentIndex: view.currentIndex;
        anchors.bottom: parent.bottom;
        anchors.horizontalCenter: parent.horizontalCenter;
    }

}
