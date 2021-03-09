import QtQuick 2.0
import Sailfish.Silica 1.0

CoverBackground {

    id: coverPage

    Label {

        id: titleLabel
        anchors.centerIn: parent
        text: qsTr("Add\nBuy")
        wrapMode: Text.Wrap
        font.pixelSize: Theme.fontSizeLarge
        horizontalAlignment: Text.AlignHCenter
        width: parent.width - 2 * Theme.horizontalPageMargin

    }

    /*
    CoverActionList {

        id: coverAction

        CoverAction {

            iconSource: "image://theme/icon-cover-new"

            onTriggered: {

                appWindow.activate();
                pageStack.replace(Qt.resolvedUrl("../pages/NewTransaction.qml"));

            }

        }

    }
    */

}
