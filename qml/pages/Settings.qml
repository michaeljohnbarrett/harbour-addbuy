import QtQuick 2.2
import Sailfish.Silica 1.0

Page {

    id: page
    allowedOrientations: Orientation.PortraitMask

    SilicaFlickable {

        anchors.fill: parent
        contentHeight: column.height

        Column {

            id: column
            width: parent.width
            spacing: Theme.paddingMedium

            PageHeader {

                title: qsTr("Settings")

            }

            SectionHeader {

                text: qsTr("Budgets & Accounts")

            }

            ComboBox {

                label: qsTr("Default Budget")
                width: parent.width
                currentIndex: settings.defaultBudgetIndex

                menu: ContextMenu {

                    Repeater {

                        model: budgetName

                        MenuItem {

                            text: modelData

                            onClicked: {

                                if (index !== settings.defaultBudgetIndex) {

                                    accountCombo.enabled = false;
                                    settings.defaultBudget = budgetID[index];
                                    settings.defaultBudgetIndex = index;
                                    settings.sync();
                                    loadingAccountsBusy.running = true;

                                    loadAccountDataForMenu('https://api.youneedabudget.com/v1/budgets/' + settings.defaultBudget + '/accounts', function (o) {

                                        var accountList = JSON.parse(o.responseText);
                                        var j = 0;
                                        var defaultAccountAssigned = false;
                                        accountsModel.clear();
                                        accountName = null;
                                        accountName = ["string"];
                                        accountID = null;
                                        accountID = ["string"];

                                        for (var i = 0; i < accountList.data.accounts.length; i++) {

                                            if (accountList.data.accounts[i].closed === false) {

                                                accountName[j] = accountList.data.accounts[i].name;
                                                accountID[j] = accountList.data.accounts[i].id;
                                                accountsModel.append({"title": accountName[j], "uuid": accountID[j]});
                                                j = j + 1;

                                            }

                                        }

                                        accountCombo.enabled = true;
                                        accountCombo.currentIndex = 0;
                                        loadingAccountsBusy.running = false;

                                    });

                                    restartAppLabel.visible = true;

                                }

                            }

                        }

                    }

                }

            }

            Label {

                visible: false
                id: restartAppLabel
                width: parent.width
                topPadding: 0
                leftPadding: recentsOldToNewSwitch.leftMargin
                text: qsTr("Please select a default account, then quit and reopen app to complete switch.")
                wrapMode: Text.Wrap
                font.pixelSize: Theme.fontSizeExtraSmall

            }

            ComboBox {

                label: qsTr("Default Account")
                width: parent.width
                currentIndex: settings.defaultAccountIndex
                id: accountCombo

                menu: ContextMenu {

                    Repeater {

                        model: accountsModel

                        MenuItem {

                            text: title

                            onClicked: {

                                accountSendReady = "account_id\": \"" + accountID[index];
                                settings.defaultAccount = accountID[index];
                                settings.defaultAccountIndex = index;
                                chosenAccount = index;
                                settings.sync();

                            }

                        }

                    }

                }

            }

            SectionHeader {

                text: qsTr("Recent Transactions")

            }

            ComboBox {

                label: qsTr("Show")
                width: parent.width
                currentIndex: settings.recentDaysBack

                menu: ContextMenu {

                    MenuItem {

                        text: qsTr("Last week")

                        onClicked: {

                            settings.recentDaysBack = 0; // 604800000
                            settings.sync();

                        }

                    }

                    MenuItem {

                        text: qsTr("Last 2 weeks")

                        onClicked: {

                            settings.recentDaysBack = 1; // 1209600000
                            settings.sync();

                        }

                    }

                    MenuItem {

                        text: qsTr("Last 30 days")

                        onClicked: {

                            settings.recentDaysBack = 2; // 2592000000
                            settings.sync();

                        }

                    }

                    MenuItem {

                        text: qsTr("Last 90 days")

                        onClicked: {

                            settings.recentDaysBack = 3; // 7776000000
                            settings.sync();

                        }

                    }

                    MenuItem {

                        text: qsTr("All transactions")

                        onClicked: {

                            settings.recentDaysBack = 4; // ""
                            settings.sync();

                        }

                    }

                }

            }

            TextSwitch {

                text: qsTr("Sort old to new")
                id: recentsOldToNewSwitch
                checked: settings.recentsOldToNew

                onCheckedChanged: {

                    settings.recentsOldToNew = checked;
                    settings.sync();

                }

            }

            TextSwitch {

                text: qsTr("Display working & cleared account balances")
                id: recentsBalanceSwitch
                checked: settings.recentsShowBalances

                onCheckedChanged: {

                    settings.recentsShowBalances = checked;
                    settings.sync();

                }

            }

            SectionHeader {

                text: qsTr("About")

            }

            Row {

                width: parent.width
                spacing: 0

                Column {

                    width: parent.width
                    spacing: 0

                    Row {

                        width: appTitleLabel.width
                        x: (parent.width - appTitleLabel.width) * 0.5
                        spacing: 0

                        Label {

                            text: qsTr("AddBuy for YNAB")
                            width: text.width
                            height: text.height
                            horizontalAlignment: Qt.AlignHCenter
                            id: appTitleLabel
                            font.pixelSize: Theme.fontSizeLarge
                            font.bold: true
                            color: Theme.highlightColor
                            bottomPadding: Theme.paddingMedium

                        }

                    }

                    Separator {

                        id: titleSeparator
                        width: appTitleLabel.width
                        x: (page.width - this.width) * 0.5
                        horizontalAlignment: Separator.Center
                        color: Theme.primaryColor

                    }
/*
                    Row {

                        width: versionLabel.width
                        x: (parent.width - this.width) * 0.5
                        spacing: 0

                        Label {

                            id: versionLabel
                            text: "v0.1"
                            font.pixelSize: Theme.fontSizeExtraSmall

                        }

                    }
*/
                    Row {

                        width: parent.width * 0.64
                        x: parent.width * 0.18
                        height: aboutTextLabel.height
                        spacing: 0

                        Label {

                            topPadding: Theme.paddingLarge
                            width: parent.width
                            id: aboutTextLabel
                            font.pixelSize: Theme.fontSizeExtraSmall
                            //font.italic: true
                            font.styleName: Theme.primaryColor
                            wrapMode: Text.Wrap
                            text: qsTr("A simple transaction-entry app for YNAB on Sailfish OS.\n\nBy Michael J. Barrett\n\nVersion 0.1\nLicensed under GNU GPLv3\n\nAddBuy for YNAB is an unofficial application and is in no way associated with You Need A Budget.")
                            bottomPadding: Theme.paddingLarge

                        }

                    }

                    Separator {

                        width: titleSeparator.width
                        x: (page.width - this.width) * 0.5
                        horizontalAlignment: Separator.Center
                        color: Theme.primaryColor

                    }

                    Row {

                        width: sendFeedbackLabel.paintedWidth
                        x: (parent.width - this.width) * 0.5
                        height: sendFeedbackLabel.height
                        spacing: 0

                        Label {

                            topPadding: Theme.paddingLarge
                            width: parent.width
                            id: sendFeedbackLabel
                            font.pixelSize: Theme.fontSizeExtraSmall
                            //font.italic: true
                            font.styleName: Theme.primaryColor
                            wrapMode: Text.Wrap
                            text: qsTr("Send feedback to")
                            bottomPadding: Theme.paddingMedium

                        }

                    }

                    Row {

                        spacing: 0
                        height: linkToBMAC.height
                        width: emailIconSeparate.width + feedbackEmail.width
                        x: (parent.width - this.width) * 0.5

                        Image {

                            id: emailIconSeparate
                            source: "image://theme/icon-m-mail"
                            fillMode: Image.PreserveAspectFit
                            height: parent.height
                            verticalAlignment: Image.AlignVCenter

                            MouseArea {

                                anchors.fill: parent
                                onClicked: Qt.openUrlExternally("mailto://mjbarrett@eml.cc?subject=AddBuy Feedback");

                            }

                        }

                        Label {

                            id: feedbackEmail
                            height: parent.height
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.highlightColor
                            text: "mjbarrett@eml.cc"
                            topPadding: 0
                            bottomPadding: this.paintedHeight * 0.17 // making this adjustment to keep vertically centered look with lowercase email.
                            leftPadding: Theme.paddingSmall
                            verticalAlignment: Text.AlignVCenter

                            MouseArea {

                                anchors.fill: parent
                                onClicked: Qt.openUrlExternally("mailto:mjbarrett@eml.cc?subject=AddBuy Feedback");

                            }

                        }

                    }



                    Row {

                        width: viewSourceCodeLabel.paintedWidth
                        x: (parent.width - this.width) * 0.5
                        height: viewSourceCodeLabel.height
                        spacing: 0

                        Label {

                            topPadding: Theme.paddingLarge
                            width: parent.width
                            id: viewSourceCodeLabel
                            font.pixelSize: Theme.fontSizeExtraSmall
                            font.styleName: Theme.primaryColor
                            wrapMode: Text.Wrap
                            text: qsTr("View source code at")
                            bottomPadding: Theme.paddingMedium

                        }

                    }
                    
                    Row {

                        width: linkToGitHub.paintedWidth
                        x: (parent.width - this.width) * 0.5
                        spacing: 0
                        height: linkToBMAC.height

                        Image {

                            id: linkToGitHub
                            source: Theme.primaryColor === "#000000" ? "GitHub_Logo.png" : "GitHub_Logo_White.png"
                            fillMode: Image.PreserveAspectFit
                            height: parent.height

                            MouseArea {

                                anchors.fill: parent
                                onClicked: Qt.openUrlExternally("https://github.com/michaeljohnbarrett/harbour-addbuy");

                            }

                        }

                    }

                    Row {

                        width: buyMeCoffeeLabel.paintedWidth
                        x: (parent.width - this.width) * 0.5
                        height: buyMeCoffeeLabel.height
                        spacing: 0

                        Label {

                            topPadding: Theme.paddingLarge
                            id: buyMeCoffeeLabel
                            font.pixelSize: Theme.fontSizeExtraSmall
                            font.styleName: Theme.primaryColor
                            wrapMode: Text.Wrap
                            text: qsTr("Support my work &")
                            bottomPadding: Theme.paddingMedium

                        }

                    }

                    Row {

                        width: parent.width * 0.4
                        x: parent.width * 0.3
                        spacing: 0
                        height: linkToBMAC.height

                        Image {

                            id: linkToBMAC
                            source: Theme.primaryColor === "#000000" ? "BMClogowithwordmark-black.png" : "BMClogowithwordmark-white.png"
                            fillMode: Image.PreserveAspectFit
                            width: parent.width

                            MouseArea {

                                    anchors.fill: parent
                                    onClicked: Qt.openUrlExternally("https://buymeacoff.ee/michaeljb");

                            }

                        }

                    }

                    Row {

                        id: bmacGapRow
                        height: Theme.paddingMedium + Theme.paddingLarge + Theme.paddingSmall
                        width: parent.width

                    }

                }

            }

        }

        BusyIndicator {

            id: loadingAccountsBusy
            size: BusyIndicatorSize.Medium
            anchors.centerIn: parent
            running: false

        }

    }

    function loadAccountDataForMenu(url, callback) {

        var accountListFromServer = new XMLHttpRequest();

        accountListFromServer.onreadystatechange = (function(myxhr) {

            return function() {

                if (myxhr.readyState === 4) {

                    callback(myxhr);

                    if (accountListFromServer.status === 200) {

                        // Accounts gathered successfully.

                    }

                    // else {

                        // Error from server.

                    // }

                }

                // else {

                    // Current network connection attempt status for accounts.

                // }

            }

        })(accountListFromServer);

        accountListFromServer.open('GET', url);
        accountListFromServer.setRequestHeader("Content-Type", "application/json");
        accountListFromServer.setRequestHeader("Accept", "application/json");
        accountListFromServer.setRequestHeader("Authorization", "Bearer " + settings.accessKey);
        accountListFromServer.send('');

    }

}
