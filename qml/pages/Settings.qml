import QtQuick 2.2
import Sailfish.Silica 1.0
import Nemo.Notifications 1.0

Page {

    id: page
    allowedOrientations: Orientation.PortraitMask

    Component.onCompleted: {

        var selectedNotFound1 = true;
        var selectedNotFound2 = true;
        var defaultAccountWorking = 0;
        var defaultAccountCleared = 1;

        for (var i = 0; i < coverBalComboModel.count; i++) {

            if (settings.coverBalance1[1] === coverBalComboModel.get(i).uuid && settings.coverBalance1[2] === coverBalComboModel.get(i).account && settings.coverBalance1[3] === coverBalComboModel.get(i).cleared) {

                coverBalance1Combo.currentIndex = i;
                selectedNotFound1 = false;

            }

            if (settings.coverBalance2[1] === coverBalComboModel.get(i).uuid && settings.coverBalance2[2] === coverBalComboModel.get(i).account && settings.coverBalance2[3] === coverBalComboModel.get(i).cleared) {

                coverBalance2Combo.currentIndex = i;
                selectedNotFound2 = false;

            }

            if (settings.defaultAccount === coverBalComboModel.get(i).uuid && coverBalComboModel.get(i).cleared === false) {

                defaultAccountWorking = i;

            }

            if (settings.defaultAccount === coverBalComboModel.get(i).uuid && coverBalComboModel.get(i).cleared === true) {

                defaultAccountCleared = i;

            }

        }

        if (selectedNotFound1) { // default account - working

            settings.coverBalance1[0] = coverBalComboModel.get(defaultAccountWorking).title;
            settings.coverBalance1[1] = coverBalComboModel.get(defaultAccountWorking).uuid;
            settings.coverBalance1[2] = coverBalComboModel.get(defaultAccountWorking).account;
            settings.coverBalance1[3] = coverBalComboModel.get(defaultAccountWorking).cleared;
            settings.sync();
            coverBalance1Combo.currentIndex = defaultAccountWorking;

        }

        if (selectedNotFound2) { // default account - cleared

            settings.coverBalance2[0] = coverBalComboModel.get(defaultAccountCleared).title;
            settings.coverBalance2[1] = coverBalComboModel.get(defaultAccountCleared).uuid;
            settings.coverBalance2[2] = coverBalComboModel.get(defaultAccountCleared).account;
            settings.coverBalance2[3] = coverBalComboModel.get(defaultAccountCleared).cleared;
            settings.sync();
            coverBalance2Combo.currentIndex = defaultAccountCleared;

        }

    }

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

                                        if (o.status === 200) {

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
                                            accountCombo.description = qsTr("Please select a default account, then quit and reopen app to complete switch.");
                                            loadingAccountsBusy.running = false;

                                        }

                                        else if (o.status === 401 || o.status === 403) {

                                            needNewKey();

                                        }

                                        else if (o.status === 503) { // need to add different handling for this status

                                            needNewKey();

                                        }

                                        else {

                                            settingsNotification.previewSummary = "Error Loading Accounts - Please Re-access Page"
                                            settingsNotification.publish();

                                        }

                                    });

                                }

                            }

                        }

                    }

                }

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

                text: qsTr("Selected account overrides default")
                id: defaultVsSelectedAccSwitch
                checked: settings.recentsShowSelectedAcc
                description: "Get data from chosen account on main page."

                onCheckedChanged: {

                    settings.recentsShowSelectedAcc = checked;
                    settings.sync();

                }

            }

            TextSwitch {

                text: qsTr("Display working & cleared balances")
                id: recentsBalanceSwitch
                checked: settings.recentsShowBalances

                onCheckedChanged: {

                    settings.recentsShowBalances = checked;
                    settings.sync();

                }

            }

            SectionHeader {

                text: qsTr("Cover Display")

            }

            ComboBox {

                label: qsTr("Balance 1:")
                width: parent.width
                id: coverBalance1Combo

                menu: ContextMenu {

                    id: coverBalance1Menu

                    Repeater {

                        model: coverBalComboModel

                        MenuItem {

                            text: title

                            onClicked: {

                                settings.coverBalance1[0] = title;
                                settings.coverBalance1[1] = uuid;
                                settings.coverBalance1[2] = account;
                                settings.coverBalance1[3] = cleared;
                                settings.sync();

                            }

                        }

                    }

                }

            }

            ComboBox {

                label: qsTr("Balance 2:")
                width: parent.width
                id: coverBalance2Combo

                menu: ContextMenu {

                    id: coverBalance2Menu

                    Repeater {

                        model: coverBalComboModel

                        MenuItem {

                            text: title

                            onClicked: {

                                settings.coverBalance2[0] = title;
                                settings.coverBalance2[1] = uuid;
                                settings.coverBalance2[2] = account;
                                settings.coverBalance2[3] = cleared;
                                settings.sync();

                            }

                        }

                    }

                }

            }

            SectionHeader {

                text: qsTr("Authorization")

            }

            Label {

                width: parent.width - Theme.horizontalPageMargin
                text: qsTr("Logout")
                leftPadding: Theme.horizontalPageMargin
                bottomPadding: 0


            }

            Label {

                id: forgetAccessKeyInfo
                width: parent.width - Theme.horizontalPageMargin
                text: qsTr("If 'Keep me logged in' was selected upon login, please instead revoke AddBuy's access from YNAB settings.\n")
                wrapMode: Text.WordWrap
                leftPadding: Theme.horizontalPageMargin
                topPadding: 0
                font.pixelSize: Theme.fontSizeExtraSmall
                color: Theme.secondaryColor

            }

            ButtonLayout {

                Button {

                    id: forgetAccessKey
                    text: "Forget Access Key"

                    onClicked: {

                        settings.accessKey = "";
                        settings.sync();
                        pageStack.clear();
                        pageStack.replace(Qt.resolvedUrl("LoadBudget.qml"));

                    }

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
                            color: Theme.primaryColor
                            bottomPadding: Theme.paddingMedium

                        }

                    }

                    Separator {

                        id: titleSeparator
                        width: appTitleLabel.width
                        x: (page.width - this.width) * 0.5
                        horizontalAlignment: Qt.AlignHCenter
                        color: Theme.highlightColor

                    }

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
                            color: Theme.primaryColor
                            wrapMode: Text.Wrap
                            text: qsTr("A simple transaction-entry app for YNAB on Sailfish OS.\n\nBy Michael J. Barrett\n\nVersion 0.2\nLicensed under GNU GPLv3\n\nApp icon by JSEHV @ GitHub. Thanks for the contribution!\n\nAddBuy for YNAB is an unofficial application and is in no way associated with You Need A Budget LLC.")
                            bottomPadding: Theme.paddingMedium

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
                            font.pixelSize: Theme.fontSizeTiny
                            font.letterSpacing: 2
                            color: Theme.highlightColor
                            wrapMode: Text.Wrap
                            text: qsTr("SUPPORT")
                            bottomPadding: Theme.paddingMedium

                        }

                    }

                    Row {

                        id: linkToBMAC2Row
                        width: parent.width * 0.6
                        x: parent.width * 0.2
                        spacing: 0
                        height: linkToBMAC2.height + (Theme.paddingMedium * 2)

                        Image {

                            id: linkToBMAC2
                            source: Theme.colorScheme == Theme.DarkOnLight ? "BMClogowithwordmark-black.png" : "BMClogowithwordmark-white.png"
                            fillMode: Image.PreserveAspectFit
                            width: parent.width
                            y: Theme.paddingMedium

                            MouseArea {

                                anchors.fill: parent
                                onClicked: Qt.openUrlExternally("https://www.buymeacoffee.com/michaeljb");

                            }

                        }

                    }

                    Row {

                        width: sendFeedbackLabel.paintedWidth
                        x: (parent.width - this.width) * 0.5
                        height: sendFeedbackLabel.height
                        spacing: 0

                        Label {

                            topPadding: Theme.paddingLarge
                            id: sendFeedbackLabel
                            font.pixelSize: Theme.fontSizeTiny
                            font.letterSpacing: 2
                            color: Theme.highlightColor
                            wrapMode: Text.Wrap
                            text: qsTr("FEEDBACK")
                            bottomPadding: Theme.paddingMedium

                        }

                    }

                    Row {

                        spacing: 0
                        height: linkToBMAC2Row.height
                        width: emailIconSeparate.width + feedbackEmail.width
                        x: (parent.width - this.width) * 0.5

                        Image {

                            id: emailIconSeparate
                            source: "image://theme/icon-m-mail"
                            verticalAlignment: Image.AlignVCenter
                            y: (parent.height - this.height) * 0.5

                            MouseArea {

                                anchors.fill: parent
                                onClicked: Qt.openUrlExternally("mailto:addbuy@mjbdev.net?subject=AddBuy Feedback");

                            }

                        }

                        Label {

                            id: feedbackEmail
                            height: parent.height
                            font.pixelSize: Theme.fontSizeLarge
                            color: Theme.primaryColor
                            text: "addbuy@mjbdev.net"
                            font.bold: true
                            topPadding: 0
                            bottomPadding: this.paintedHeight * 0.1
                            leftPadding: Theme.paddingSmall
                            verticalAlignment: Text.AlignVCenter

                            MouseArea {

                                anchors.fill: parent
                                onClicked: Qt.openUrlExternally("mailto:addbuy@mjbdev.net?subject=AddBuy Feedback");

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
                            id: viewSourceCodeLabel
                            font.pixelSize: Theme.fontSizeTiny
                            font.letterSpacing: 2
                            color: Theme.highlightColor
                            wrapMode: Text.Wrap
                            text: qsTr("SOURCE")
                            bottomPadding: Theme.paddingMedium

                        }

                    }

                    Row {

                        width: linkToGitHub.paintedWidth
                        x: (parent.width - this.width) * 0.5
                        spacing: 0
                        height: linkToBMAC2Row.height

                        Image {

                            id: linkToGitHub
                            source: Theme.colorScheme == Theme.DarkOnLight ? "GitHub_Logo.png" : "GitHub_Logo_White.png"
                            fillMode: Image.PreserveAspectFit
                            height: parent.height

                            MouseArea {

                                anchors.fill: parent
                                onClicked: Qt.openUrlExternally("https://github.com/michaeljohnbarrett/harbour-addbuy");

                            }

                        }

                    }

                    Row {

                        id: bmacGapRow
                        height: Theme.paddingLarge
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

    Notification {

        id: settingsNotification
        isTransient: true
        appName: "AddBuy"
        expireTimeout: 2000

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

                    else if (accountListFromServer.status === 401 || accountListFromServer.status === 403) {

                        // do something

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
