import QtQuick 2.15
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.3

Rectangle{
    anchors.top: parent.top;
    anchors.left: parent.left;
    anchors.right: parent.right;
    anchors.bottom: parent.verticalCenter;
    anchors.leftMargin: 10;
    anchors.rightMargin: 10;
    anchors.topMargin: 10;
    anchors.bottomMargin: 20;
    color : "#21373d";
    Column{
        spacing: 10;
        anchors.fill: parent;
        Rectangle{
            radius: 6;
            height:40;
            width:parent.width;
            color:"#0eb0c9";
            Row{
                leftPadding: 10;
                anchors.verticalCenter: parent.verticalCenter;
                anchors.fill: parent;
                spacing: 20;
                Rectangle{
                    anchors.verticalCenter: parent.verticalCenter;
                    height:30;
                    width: 5;
                    radius: 2;
                    //color: "#eef7f2";
                    gradient: Gradient {
                        GradientStop {  position: 0.0;    color: "#ef82a0"  }
                        GradientStop {  position: 1.0;    color: "#ec2d7a" }
                    }
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter;
                    id: temp_text;
                    text: qsTr("温度");
                    font.pixelSize: 24;
                    color:"#eef7f2";
                }
                Rectangle{
                    radius: 4;
                    height:30;
                    width:parent.width-150;
                    anchors.verticalCenter: parent.verticalCenter;
                    color: "#132c33";

                    Text {
                        anchors.centerIn: parent;
                        text: qsTr("37");
                        font.pixelSize: 24;
                        color:"#eef7f2";
                    }

                }
            }
        }
        Rectangle{
            radius: 6;
            height:40;
            width:parent.width;
            color:"#0eb0c9";
            Row{
                leftPadding: 10;
                anchors.verticalCenter: parent.verticalCenter;
                anchors.fill: parent;
                spacing: 20;
                Rectangle{
                    anchors.verticalCenter: parent.verticalCenter;
                    height:30;
                    width: 5;
                    radius: 2;
                    gradient: Gradient {
                        GradientStop {  position: 0.0;    color: "#96c24e"  }
                        GradientStop {  position: 1.0;    color: "#2c9678" }
                    }
                }
                Text {
                    anchors.verticalCenter: parent.verticalCenter;
                    id: water_level_text;
                    text: qsTr("水位");
                    font.pixelSize: 24;
                    color:"#eef7f2";
                }
                Rectangle{
                    radius: 4;
                    height:30;
                    width:parent.width-150;
                    anchors.verticalCenter: parent.verticalCenter;
                    color:"#132c33";
                    Text {
                        anchors.centerIn: parent;
                        text: qsTr("37");
                        font.pixelSize: 24;
                        color:"#eef7f2";
                    }

                }
            }
        }
        Rectangle{
            radius: 6;
            height:40;
            width:parent.width;
            color:"#525288";
            Row{
                leftPadding: 10;
                anchors.verticalCenter: parent.verticalCenter;
                anchors.fill: parent;
                spacing: 20;
                Rectangle{
                    anchors.verticalCenter: parent.verticalCenter;
                    height:30;
                    width: 5;
                    radius: 2;
                    //color: "#e2e1e4";
                    gradient: Gradient {
                        GradientStop {  position: 0.0;    color: "#f8d86a"  }
                        GradientStop {  position: 1.0;    color: "#f1ca17" }
                    }
                }
                Text {
                    anchors.verticalCenter: parent.verticalCenter;
                    id: used_time_text;
                    text: qsTr("已用时");
                    font.pixelSize: 24;
                    color:"#e2e1e4";
                }
                Rectangle{
                    radius: 4;
                    height:30;
                    width:parent.width-150;
                    anchors.verticalCenter: parent.verticalCenter;
                    color:"#131124";
                    Text {
                        anchors.centerIn: parent;
                        text: qsTr("37");
                        font.pixelSize: 24;
                        color:"#e2e1e4";
                    }

                }
            }
        }
        Rectangle{
            radius: 6;
            height:40;
            width:parent.width;
            color:"#525288";
            Row{
                leftPadding: 10;
                anchors.verticalCenter: parent.verticalCenter;
                anchors.fill: parent;
                spacing: 20;
                Rectangle{
                    anchors.verticalCenter: parent.verticalCenter;
                    height:30;
                    width: 5;
                    radius: 2;
                    //color: "#e2e1e4";
                    gradient: Gradient {
                        GradientStop {  position: 0.0;    color: "#ad6598"  }
                        GradientStop {  position: 1.0;    color: "#7e1671" }
                    }
                }
                Text {
                    anchors.verticalCenter: parent.verticalCenter;
                    id: remaining_time_text;
                    text: qsTr("剩余时");
                    font.pixelSize: 24;
                    color:"#e2e1e4";
                }
                Rectangle{
                    radius: 4;
                    height:30;
                    width:parent.width-150;
                    anchors.verticalCenter: parent.verticalCenter;
                    color:"#131124";
                    Text {
                        anchors.centerIn: parent;
                        text: qsTr("37");
                        font.pixelSize: 24;
                        color:"#e2e1e4";
                    }

                }
            }
        }
    }

}
