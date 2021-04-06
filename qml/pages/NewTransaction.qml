import QtQuick 2.6
import Sailfish.Silica 1.0
import Nemo.Notifications 1.0
import NetworkPostAccess 1.0

Page {

    id: page
    allowedOrientations: Orientation.PortraitMask
    property string chosenPayee
    property bool notOperator

    Component.onCompleted: {

        accountBox.currentIndex = chosenAccount;
        shadowAmount.text = costFigure.text;
        figureRectangle.width = shadowAmount.paintedWidth + (Theme.paddingMedium * 4);
        figureRectangle.height = shadowAmount.paintedHeight + (Theme.paddingMedium * 4);

    }

    NetworkPostAccess {

        id: httpPostInCPP

        onFinished: {

            if (responseCode === 201) {

                var responseParsed = JSON.parse(responseText);

                if (responseParsed.data.transaction.category_name !== null) {

                    assignedCategory = responseParsed.data.transaction.category_name;
                    transactionSaved.previewSummary = "Transaction Saved"
                    savingBusy.running = false;
                    transactionSaved.publish();

                }

                else {

                    transactionSaved.previewSummary = "Invalid Category, Remaining Data Saved";
                    savingBusy.running = false;
                    transactionSaved.publish();

                }

            }

            else {

                savingBusy.running = false;
                transactionNotSaved.publish();

            }

            costFigure.text = "";
            searchField.text = "";
            payeeListModel.clear();
            categoryBox.currentIndex = 0;
            clearedSwitch.checked = false;
            memoSwitch.checked = false;

        }

    }

    SilicaFlickable {

        anchors.fill: parent
        id: mainFlickable

        PullDownMenu {

            MenuItem {

                text: qsTr("Save Transaction")

                onClicked: {

                    savingBusy.running = true;
                    var clearedStatus = "\"cleared\": \"uncleared\",";
                    var memoSendReady = "";
                    if (clearedSwitch.checked === true) clearedStatus = "\"cleared\": \"cleared\",";
                    if (memoSwitch.checked) memoSendReady = "\"memo\": \"" + memoText.text + "\",";
                    var todaysDate = new Date();
                    var adjustedAmount = costFigure.text;
                    adjustedAmount = adjustedAmount.replace(/\D+/g, '');
                    amountSendReady = parseFloat(adjustedAmount);
                    if (decimalPlaces !== 3) amountSendReady = amountSendReady * 10;
                    chosenPayee = chosenPayee.replace(":", "\\:"); // avoiding errors when saving
                    var saveTransactionUrl = "https://api.youneedabudget.com/v1/budgets/" + settings.defaultBudget + "/transactions";
                    var data = "{\"transaction\": {\"" + accountSendReady + "\",\"date\": \"" + todaysDate.toISOString().substring(0, 10) + "\",\"amount\":-" + amountSendReady + "," + categorySendReady + payeeSendReady + memoSendReady + clearedStatus + "\"approved\": true}}"
                    httpPostInCPP.post(saveTransactionUrl, data, "Bearer " + settings.accessKey);

                }

            }

        }

        PushUpMenu {

            MenuItem {

                text: qsTr("Recent Transactions")

                onClicked: {

                    pageStack.push(Qt.resolvedUrl("Recent.qml"));

                }

            }

            MenuItem {

                text: qsTr("Budget Categories")

                onClicked: {

                    pageStack.push(Qt.resolvedUrl("Categories.qml"));

                }

            }

            MenuItem {

                text: qsTr("Settings")

                onClicked: {

                    pageStack.push(Qt.resolvedUrl("Settings.qml"));

                }

            }

        }

        contentHeight: column.height

        Column {

            id: column
            width: page.width
            spacing: Theme.paddingMedium

            PageHeader {

                title: qsTr("AddBuy")
                id: mainHeader

            }

            Row {

                id: currencyRow
                width: parent.width * 0.4
                height: figureRectangle.height + Theme.paddingLarge
                spacing: 0
                visible: opacity !== 0.0
                x: (parent.width - figureRectangle.width) / 2

                Behavior on opacity {

                    FadeAnimator {

                        duration: 200

                    }

                }

                Rectangle {

                    id: figureRectangle
                    smooth: true
                    opacity: 1.0
                    height: shadowAmount.paintedHeight + (Theme.paddingLarge * 2)
                    width: shadowAmount.paintedWidth + (Theme.paddingLarge * 4)
                    radius: 20
                    color: "transparent"

                    border {

                        width: 1
                        color: Theme.primaryColor

                    }

                    TextField {

                        id: costFigure
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        width: shadowAmount.paintedWidth + (Theme.paddingLarge * 2)
                        color: Theme.primaryColor
                        textLeftMargin: Theme.paddingMedium + (Theme.paddingSmall * 0.5)
                        textRightMargin: Theme.paddingMedium - (Theme.paddingSmall * 0.5)
                        textTopMargin: Theme.paddingMedium
                        horizontalAlignment: TextInput.AlignHCenter
                        font.pixelSize: Theme.fontSizeHuge
                        font.letterSpacing: 2
                        font.bold: false
                        maximumLength: 14
                        text: currencySymbol[4]
                        background: null
                        Keys.onEscapePressed: this.focus = false;
                        y: Theme.paddingMedium
                        x: 0

                        EnterKey.onClicked: {

                            if (searchField.text === "") searchField.focus = true;
                            else this.focus = false;

                        }

                        onCursorPositionChanged: {

                            if (text.length > 0) {

                                if (symbolFirst) cursorPosition = text.length;
                                else cursorPosition = text.length - (currencySymbol[4].length);

                            }

                        }

                        onClicked: {

                            if (text.length > 0) {

                                if (symbolFirst) cursorPosition = text.length;
                                else cursorPosition = text.length - (currencySymbol[4].length);

                            }

                        }

                        onTextChanged: {

                            if(notOperator === false) {

                                notOperator = true; // So as to not loop back to this part of the textChanged function when these changes are made.

                                if (text === "" || text === currencySymbol[4]) {  //  <-- need to fix as this is no longer required if field already has formatted zero amount?

                                    if (decimalPlaces === 3) {

                                        if (symbolFirst) text = currencySymbol[4] + "0" + decimalSeparator + "000";
                                        else text = "0" + decimalSeparator + "000" + currencySymbol[4];

                                    }

                                    else if (decimalPlaces === 2) {

                                        if (symbolFirst) text = currencySymbol[4] + "0" + decimalSeparator + "00";
                                        else text = "0" + decimalSeparator + "00" + currencySymbol[4];

                                    }

                                    else { // decimalPlaces = 0

                                        if (symbolFirst) text = currencySymbol[4] + "0";
                                        else text = "0" + currencySymbol[4];

                                    }

                                }

                                else {

                                    // firstly remove all non-numerics to re-evaluate digits and then place back in correct positions.

                                    text = text.replace(/\D+/g, '');


                                    if (decimalPlaces === 0) {

                                        if (text.length > 9) { // who knows could be a billion something transaction...

                                            text = text.slice(0, (text.length - 9)) + groupSeparator + text.slice((text.length - 9), (text.length - 6)) + groupSeparator + text.slice((text.length - 6), (text.length - 3)) + groupSeparator + text.slice((text.length - 3), text.length);

                                        }

                                        else if (text.length > 6) {

                                            text = text.slice(0, (text.length - 6)) + groupSeparator + text.slice((text.length - 6), (text.length - 3)) + groupSeparator + text.slice((text.length - 3), text.length);

                                        }

                                        else if (text.length > 3) {

                                            text = text.slice(0, (text.length - 3)) + groupSeparator + text.slice((text.length - 3), text.length);

                                        }

                                        else if (text.length === 2) {

                                            if (text.charAt(0) === "0") text = text.charAt(1);

                                        }

                                    }

                                    else if (text.length > decimalPlaces) {

                                        if (text.length > (decimalPlaces + 1)) { // allowing for one '0' in front of decimal separator.

                                            if (text.charAt(0) === "0") text = text.slice(1, text.length);

                                        }

                                        text = text.slice(0, (text.length - decimalPlaces)) + decimalSeparator + text.slice((text.length - decimalPlaces), text.length);

                                        // with decimalPlaces of two (YNAB settings do not appear to have an option for one) or more, there's not going to be room for three groupSeparators, so fewer options necessary than above.

                                        if (text.length > (7 + decimalPlaces)) { // decimalSeparator has been added to string so factoring this in (7 not 6).

                                            text = text.slice(0, (text.length - (7 + decimalPlaces))) + groupSeparator + text.slice((text.length - (7 + decimalPlaces)), (text.length - (4 + decimalPlaces))) + groupSeparator + text.slice((text.length - (4 + decimalPlaces)), text.length);

                                        }

                                        else if (text.length > (4 + decimalPlaces)) {

                                            text = text.slice(0, (text.length - (4 + decimalPlaces))) + groupSeparator + text.slice((text.length - (4 + decimalPlaces)), text.length);

                                        }

                                    }

                                    else if (text.length === decimalPlaces) text = "0" + decimalSeparator + text;

                                    // put back currency symbol
                                    if (symbolFirst) text = currencySymbol[4] + text;
                                    else text = text + currencySymbol[4];

                                }

                                shadowAmount.text = text;
                                figureRectangle.width = shadowAmount.paintedWidth + (Theme.paddingMedium * 4);
                                figureRectangle.height = shadowAmount.paintedHeight + (Theme.paddingMedium * 4);
                                notOperator = false; // Back to normal for user input.

                            }

                        }

                    }

                }

                // invisible label for centering purposes.
                Label {

                    padding: 0
                    visible: false
                    id: shadowAmount
                    text: costFigure.text
                    font.pixelSize: Theme.fontSizeHuge
                    font.letterSpacing: 2
                    horizontalAlignment: TextInput.AlignHCenter
                    color: Theme.primaryColor
                    font.bold: false

                }

            }

            Row {

                id: payeeFieldRow
                width: parent.width
                spacing: Theme.paddingMedium

                TextField {

                    id: searchField
                    width: parent.width
                    placeholderText: qsTr("Payee")
                    font.pixelSize: Theme.fontSizeMedium
                    background: null
                    labelVisible: false

                    Keys.onEscapePressed: {

                        this.focus = false;

                    }

                    onFocusChanged: {

                        if (this.focus) {

                            currencyRow.opacity = 0.0;
                            categoryBox.visible = false;
                            accountBox.visible = false;
                            clearedSwitch.visible = false;
                            memoSwitch.visible = false;
                            if (memoSwitch.checked) memoText.visible = false;

                        }

                        else {

                            chosenPayee = searchField.text;
                            chosenPayee = chosenPayee.replace(":", "\\:"); // avoiding errors when saving
                            payeeSendReady = "\"payee_name\": \"" + chosenPayee + "\",";
                            currencyRow.opacity = 1.0;
                            categoryBox.visible = true;
                            accountBox.visible = true;
                            clearedSwitch.visible = true;
                            memoSwitch.visible = true;
                            if (memoSwitch.checked) memoText.visible = true;
                            payeeListModel.clear();

                            // if user moved on by just tapping outside field, as opposed to enter key or selecting an existing payee,
                            // possible that it's a new payee and so directing user to choose a category as leaving choice as 'default'
                            // will result in no category being assigned.
                            if (chosenPayee !== "") categoryBox.focus = true;

                        }

                    }

                    onTextChanged: {

                        payeeListModel.update()

                    }

                    EnterKey.onClicked: {

                        // needs to be at least one result to work with
                        if (payeeListModel.count > 0 && text.length > 0) {

                            // enter key will choose top result
                            endPayeeSearch(payeeListModel.get(0).name);

                        }

                    }

                }

            }

            Row {

                width: parent.width
                height: column3.height

                Behavior on y {

                    NumberAnimation {

                        duration: 200

                    }

                }

                Column {

                    id: column3
                    width: parent.width

                    ListView {

                        width: parent.width
                        height: searchField.focus ? page.height - (mainHeader.height + currencyRow.height + payeeFieldRow.height + (Theme.paddingMedium * 2)) : 0

                        // prevent newly added list delegates from stealing focus away from the search field
                        currentIndex: -1

                        model: ListModel {

                            id: payeeListModel

                            function update() {

                                // payeeTextField.text = payeeSearchListView.headerItem.text; // match with textfield incase user hides search and wants to leave as is (new payee).
                                clear();

                                for (var i = 0; i < payeeName.length; i++) {

                                    if (searchField.text === "" || payeeNameToUpperCase[i].indexOf(searchField.text.toUpperCase()) >= 0) {

                                        append({"name": payeeName[i]});

                                    }

                                }

                            }

                        }

                        delegate: ListItem {

                            id: payeeSearchListItem


                            onClicked: {

                                endPayeeSearch(name);

                            }

                            Label {

                                anchors {

                                    left: parent.left
                                    leftMargin: searchField.textLeftMargin
                                    right: parent.right
                                    rightMargin: Theme.horizontalPageMargin
                                    verticalCenter: parent.verticalCenter

                                }

                                padding: 0
                                text: name
                                fontSizeMode: Theme.fontSizeSmall
                                verticalAlignment: "AlignVCenter"

                            }

                        }

                    }

                }

            }

            Row {

                width: parent.width
                spacing: Theme.paddingMedium

                ComboBox {

                    id: categoryBox
                    label: qsTr("Category")

                    menu: ContextMenu {

                        id: categoryMenu

                        Repeater {

                            model: categoryName

                            MenuItem {

                                text: modelData

                                onClicked: {

                                    if (index === 0) categorySendReady = "";
                                    else categorySendReady = "\"category_id\": \"" + categoryID[index] + "\",";

                                }

                            }

                        }

                    }

                }

            }

            Row {

                width: parent.width
                spacing: Theme.paddingMedium

                ComboBox {

                    id: accountBox
                    label: qsTr("Account")
                    currentIndex: chosenAccount

                    menu: ContextMenu {

                        id: accountMenu

                        Repeater {

                            model: accountsModel

                            MenuItem {

                                text: title

                                onClicked: {

                                    accountSendReady = "account_id\": \"" + accountID[index];
                                    chosenAccount = index;

                                }

                            }

                        }

                    }

                }

            }

            Row {

                width: parent.width
                spacing: Theme.paddingMedium

                TextSwitch {

                    id: clearedSwitch
                    text: qsTr("Cleared")

                }

            }

            Row {

                width: parent.width
                spacing: Theme.paddingMedium

                TextSwitch {

                    id: memoSwitch
                    text: qsTr("Memo")

                    onCheckedChanged: {

                        if (this.checked) {

                            memoText.visible = true;
                            memoText.forceActiveFocus();

                        }

                        else {

                            memoText.visible = false;
                            memoText.text = "";

                        }

                    }

                }

            }

            Row {

                width: parent.width
                spacing: Theme.paddingMedium

                TextArea {

                    label: "200/200"
                    id: memoText
                    wrapMode: TextEdit.Wrap
                    autoScrollEnabled: true
                    visible: false
                    width: parent.width
                    EnterKey.iconSource: "image://theme/icon-m-enter-close"

                    EnterKey.onClicked: {

                        text = text.substring(0, (text.length - 1));
                        this.focus = false;

                    }

                    onTextChanged: {

                        if (length > 200) {

                            text = text.substring(0, 200);
                            cursorPosition = 200;
                            label = "0/200";

                        }

                        else {

                            label = (200 - length) + "/200";

                        }

                    }

                }

            }

        }

        Notification {

            id: transactionSaved
            previewSummary: qsTr("Transaction Saved")
            appName: "AddBuy"
            isTransient: true
            urgency: Notification.Low
            expireTimeout: 1250

        }

        Notification {

            id: transactionNotSaved
            previewSummary: qsTr("Transaction Not Saved - Authentication or formatting error")
            appName: "AddBuy"
            isTransient: false
            expireTimeout: 2500

        }

        BusyIndicator {

            id: savingBusy
            size: BusyIndicatorSize.Large
            anchors.centerIn: parent
            running: false

        }

    }

    function endPayeeSearch(payeeText) {

        for (var i = 0; i < payeeName.length; i++) {

            if (payeeName[i] === payeeText) {

                chosenPayee = payeeName[i];
                i = payeeName.length; // exit loop now that we've found the ID

            }

        }

        categoryBox.visible = true;
        accountBox.visible = true;
        clearedSwitch.visible = true;
        memoSwitch.visible = true;
        if (memoSwitch.checked) memoText.visible = true;
        searchField.text = chosenPayee; // need to put this line after components made visible again.
        chosenPayee = chosenPayee.replace(":", "\\:"); // avoiding errors when saving
        payeeSendReady = "\"payee_name\": \"" + chosenPayee + "\",";
        payeeListModel.clear();
        searchField.focus = false;

    }

}
