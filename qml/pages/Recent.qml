import QtQuick 2.6
import Sailfish.Silica 1.0
import Nemo.Notifications 1.0

Page {

    id: page
    allowedOrientations: Orientation.All

    ListModel {

        id: recentTransactionsModel

        ListElement {

            dateShort: "..."; date: "..."; payee: qsTr("Loading..."); category: "..."; inflow: "..."; outflow: "..."; uncleared: false

        }

    }
    /*
    onOrientationChanged: {

        if (page.orientation === Orientation.Portrait || ) {



        }

    }
*/
    Component.onCompleted: {

        if (settings.recentsShowSelectedAcc) chosenRecentsAccount = chosenAccount;
        else chosenRecentsAccount = settings.defaultAccountIndex;
        recentAccountBox.currentIndex = chosenRecentsAccount;

        var todaysDate = new Date();
        var cutOffDate = new Date();

        switch (settings.recentDaysBack) {

        case 0:
            cutOffDate.setTime(todaysDate.getTime() - 604800000);
            sinceDate = "?since_date=" + cutOffDate.toISOString().substring(0, 10);
            break;
        case 1:
            cutOffDate.setTime(todaysDate.getTime() - 1209600000);
            sinceDate = "?since_date=" + cutOffDate.toISOString().substring(0, 10);
            break;
        case 2:
            cutOffDate.setTime(todaysDate.getTime() - 2592000000);
            sinceDate = "?since_date=" + cutOffDate.toISOString().substring(0, 10);
            break;
        case 3:
            cutOffDate.setTime(todaysDate.getTime() - 7776000000);
            sinceDate = "?since_date=" + cutOffDate.toISOString().substring(0, 10);
            break;
        case 4:
            sinceDate = "";

        }

        var l = chosenRecentsAccount;

        loadRecentTransactions('https://api.youneedabudget.com/v1/budgets/' + settings.defaultBudget + '/accounts/' + accountID[l] + '/transactions' + sinceDate, function (o) {

            // render YNAB's date format compatible with Qt's:
            dateFormat = dateFormat.replace(/DD/, "dd");
            dateFormat = dateFormat.replace(/YYYY/, "yyyy");
            // need to shorten somewhat in portrait mode for spacing
            var shortDateFormat = dateFormat.replace(/yyyy/, "yy");

            var recentTransactionList = JSON.parse(o.responseText);

            if (o.status === 200) {

                recentTransactionsModel.clear(); // clear the existing one line

                var j = recentTransactionList.data.transactions.length;

                for (var i = 0; i < recentTransactionList.data.transactions.length; i++) {

                    j--;
                    recentsDate[j] = Qt.formatDate(recentTransactionList.data.transactions[i].date, dateFormat);
                    recentsDateShort[j] = Qt.formatDate(recentTransactionList.data.transactions[i].date, shortDateFormat);
                    recentsPayee[j] = recentTransactionList.data.transactions[i].payee_name;
                    recentsCategory[j] = recentTransactionList.data.transactions[i].category_name;

                    if (recentTransactionList.data.transactions[i].amount >= 0) { // amount is income

                        recentsInflow[j] = formatFigure(recentTransactionList.data.transactions[i].amount);
                        recentsOutflow[j] = "";

                    }

                    else { // amount is expenditure, * -1 since don't need minus sign in column

                        recentsOutflow[j] = formatFigure(recentTransactionList.data.transactions[i].amount * -1);
                        recentsInflow[j] = "";

                    }

                    if (recentTransactionList.data.transactions[i].cleared === "cleared" || recentTransactionList.data.transactions[i].cleared === "reconciled") recentsUncleared[j] = false;
                    else recentsUncleared[j] = true;

                    // if user has chosen to list recents as oldest to newest, we can just add each one now as the order doesn't need to be reversed.
                    if (settings.recentsOldToNew === true) {

                        recentTransactionsModel.append({ dateShort: recentsDateShort[j], date: recentsDate[j], payee: recentsPayee[j], category: recentsCategory[j], inflow: recentsInflow[j], outflow: recentsOutflow[j], uncleared: recentsUncleared[j] });

                    }

                }

                if (settings.recentsOldToNew === false) {

                    for (var k = 0; k < recentTransactionList.data.transactions.length; k++) {

                        recentTransactionsModel.append({ dateShort: recentsDateShort[k], date: recentsDate[k], payee: recentsPayee[k], category: recentsCategory[k], inflow: recentsInflow[k], outflow: recentsOutflow[k], uncleared: recentsUncleared[k] });

                    }

                }

                if (settings.recentsShowBalances) {

                    loadAccountBalances('https://api.youneedabudget.com/v1/budgets/' + settings.defaultBudget + '/accounts/' + accountID[l], function (o) {

                        var accountBalances = JSON.parse(o.responseText);

                        if (o.status === 200) {

                            workingBalance = formatFigure(accountBalances.data.account.balance);
                            clearedBalance = formatFigure(accountBalances.data.account.cleared_balance);

                        }
/* -- see note for identical code for accounts menu
                        else if (o.status === 401 || o.status === 403) {

                            needNewKey();

                        }
*/
                        else {

                            unknownError.previewSummary = qsTr("Unknown Error - Unable to Load Account Balances");
                            unknownError.publish();

                        }

                    });

                }

                //recentsListView.forceLayout(); // was possible cause of issue when accessing recent transactions after key expiration (blank page)

            }

            else if (o.status === 401 || o.status === 403) {

                needNewKey();

            }

            else {

                unknownError.previewSummary = qsTr("Unknown Error - Unable to Load Transactions");
                unknownError.publish();

            }

        });

    }

    SilicaListView {

        anchors.fill: parent
        contentHeight: column.height
        id: mainListView

        Column {

            id: column
            width: parent.width

            PageHeader {

                title: qsTr("Recent Transactions")
                id: recentsPageHeader
                visible: isPortrait ? true : false

            }

            Row {

                width: parent.width
                id: accountBoxRow
                visible: isPortrait ? true : false

                ComboBox {

                    label: qsTr("Account")
                    id: recentAccountBox

                    menu: ContextMenu {

                        id: accountMenu

                        Repeater {

                            model: accountName

                            MenuItem {

                                text: modelData

                                onClicked: {

                                    if (index !== chosenRecentsAccount) {

                                        chosenRecentsAccount = index;

                                        loadRecentTransactions('https://api.youneedabudget.com/v1/budgets/' + settings.defaultBudget + '/accounts/' + accountID[chosenRecentsAccount] + '/transactions' + sinceDate, function (o) {

                                            dateFormat = dateFormat.replace(/DD/, "dd");
                                            dateFormat = dateFormat.replace(/YYYY/, "yyyy");
                                            var shortDateFormat = dateFormat.replace(/yyyy/, "yy");

                                            var recentTransactionList = JSON.parse(o.responseText);

                                            if (o.status === 200) {

                                                recentTransactionsModel.clear();

                                                var j = recentTransactionList.data.transactions.length;

                                                for (var i = 0; i < recentTransactionList.data.transactions.length; i++) {

                                                    j--;

                                                    recentsDate[j] = Qt.formatDate(recentTransactionList.data.transactions[i].date, dateFormat);
                                                    recentsDateShort[j] = Qt.formatDate(recentTransactionList.data.transactions[i].date, shortDateFormat);
                                                    recentsPayee[j] = recentTransactionList.data.transactions[i].payee_name;
                                                    recentsCategory[j] = recentTransactionList.data.transactions[i].category_name;

                                                    if (recentTransactionList.data.transactions[i].amount >= 0) {

                                                        recentsInflow[j] = formatFigure(recentTransactionList.data.transactions[i].amount);
                                                        recentsOutflow[j] = "";

                                                    }

                                                    else {

                                                        recentsOutflow[j] = formatFigure(recentTransactionList.data.transactions[i].amount * -1);
                                                        recentsInflow[j] = "";

                                                    }

                                                    if (recentTransactionList.data.transactions[i].cleared === "cleared" || recentTransactionList.data.transactions[i].cleared === "reconciled") recentsUncleared[j] = false;
                                                    else recentsUncleared[j] = true;

                                                    if (settings.recentsOldToNew === true) {

                                                        recentTransactionsModel.append({ dateShort: recentsDateShort[j], date: recentsDate[j], payee: recentsPayee[j], category: recentsCategory[j], inflow: recentsInflow[j], outflow: recentsOutflow[j], uncleared: recentsUncleared[j] });

                                                    }

                                                }

                                                if (settings.recentsOldToNew === false) {

                                                    for (var k = 0; k < recentTransactionList.data.transactions.length; k++) {

                                                        recentTransactionsModel.append({ dateShort: recentsDateShort[k], date: recentsDate[k], payee: recentsPayee[k], category: recentsCategory[k], inflow: recentsInflow[k], outflow: recentsOutflow[k], uncleared: recentsUncleared[k] });

                                                    }

                                                }

                                                if (settings.recentsShowBalances) {

                                                    loadAccountBalances('https://api.youneedabudget.com/v1/budgets/' + settings.defaultBudget + '/accounts/' + accountID[chosenRecentsAccount], function (o) {

                                                        var accountBalances = JSON.parse(o.responseText);

                                                        if (o.status === 200) {

                                                            workingBalance = formatFigure(accountBalances.data.account.balance);
                                                            clearedBalance = formatFigure(accountBalances.data.account.cleared_balance);
                                                            clearedBalanceFigureLabel.text = "";
                                                            clearedBalanceFigureLabel.text = clearedBalance;
                                                            workingBalanceFigureLabel.text = "";
                                                            workingBalanceFigureLabel.text = workingBalance;

                                                        }
/* -- leave this to the recent transactions function to catch, possible that both functions calling 'needNewKey' was causing an issue
                                                        else if (o.status === 401 || o.status === 403) {

                                                            needNewKey();

                                                        }
*/
                                                        else {

                                                            unknownError.previewSummary = qsTr("Unknown Error - Unable to Load Account Balances");
                                                            unknownError.publish();

                                                        }

                                                    });

                                                }

                                                //recentsListView.forceLayout();

                                            }

                                            else if (o.status === 401 || o.status === 403) {

                                                needNewKey();

                                            }

                                            else {

                                                unknownError.previewSummary = qsTr("Unknown Error - Unable to Load Transactions");
                                                unknownError.publish();

                                            }

                                        });

                                    }

                                }

                            }

                        }

                    }

                }

            }

            Row {

                id: balancesRow
                width: parent.width
                spacing: Theme.paddingSmall
                x: Theme.horizontalPageMargin
                visible: isPortrait ? settings.recentsShowBalances ? true : false : false

                Label {

                    id: clearedBalanceLabel
                    width: parent.width * 0.25 - (Theme.horizontalPageMargin)
                    text: qsTr("Cleared:")
                    font.pixelSize: Theme.fontSizeExtraSmall
                    bottomPadding: Theme.paddingMedium

                }

                Label {

                    id: clearedBalanceFigureLabel
                    width: parent.width * 0.25 - (Theme.paddingSmall * 4)
                    horizontalAlignment: Text.AlignRight
                    text: clearedBalance
                    font.pixelSize: Theme.fontSizeExtraSmall
                    bottomPadding: Theme.paddingMedium

                }

                Label {

                    text: " | "
                    width: Theme.paddingSmall * 4
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: Theme.fontSizeExtraSmall
                    color: Theme.secondaryColor
                    bottomPadding: Theme.paddingMedium

                }

                Label {

                    id: workingBalanceLabel
                    width: parent.width * 0.25 - (Theme.horizontalPageMargin)
                    text: qsTr("Working:")
                    font.pixelSize: Theme.fontSizeExtraSmall
                    bottomPadding: Theme.paddingMedium

                }

                Label {

                    id: workingBalanceFigureLabel
                    width: parent.width * 0.25 - (Theme.paddingSmall * 4)
                    horizontalAlignment: Text.AlignRight
                    text: workingBalance
                    font.pixelSize: Theme.fontSizeExtraSmall
                    bottomPadding: Theme.paddingMedium

                }

            }

            Row {

                id: balancesDividerRow
                width: parent.width
                x: Theme.horizontalPageMargin
                visible: isPortrait ? settings.recentsShowBalances ? true : false : false

                Separator {

                    horizontalAlignment: Qt.AlignHCenter
                    width: parent.width - (Theme.horizontalPageMargin)
                    primaryColor: Theme.primaryColor

                }

            }

            Row {

                width: parent.width - (Theme.horizontalPageMargin * 2)
                spacing: Theme.paddingSmall
                id: recentsHeaderRow
                x: Theme.horizontalPageMargin

                Label {

                    text: qsTr("Date")
                    font.pixelSize: isPortrait ? Theme.fontSizeExtraSmall : Theme.fontSizeSmall
                    color: Theme.secondaryColor
                    width: isPortrait ? parent.width * 0.18 : parent.width * 0.14
                    topPadding: Theme.paddingSmall
                    bottomPadding: Theme.paddingSmall

                }

                Label {

                    text: qsTr("Payee")
                    font.pixelSize: isPortrait ? Theme.fontSizeExtraSmall : Theme.fontSizeSmall
                    color: Theme.secondaryColor
                    width: isPortrait ? (parent.width * 0.4) - Theme.paddingSmall : (parent.width * 0.27) - Theme.paddingSmall
                    topPadding: Theme.paddingSmall
                    bottomPadding: Theme.paddingSmall

                }

                Label {

                    text: qsTr("Category")
                    visible: isPortrait ? false : true
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.secondaryColor
                    width: parent.width * 0.27 - Theme.paddingSmall
                    topPadding: Theme.paddingSmall
                    bottomPadding: Theme.paddingSmall

                }

                Label {

                    text: qsTr("Inflow")
                    font.pixelSize: isPortrait ? Theme.fontSizeExtraSmall : Theme.fontSizeSmall
                    color: Theme.secondaryColor
                    horizontalAlignment: "AlignRight"
                    width: isPortrait ? (parent.width * 0.21) - Theme.paddingSmall : parent.width * 0.16 - Theme.paddingSmall
                    topPadding: Theme.paddingSmall
                    bottomPadding: Theme.paddingSmall

                }

                Label {

                    text: qsTr("Outflow")
                    font.pixelSize: isPortrait ? Theme.fontSizeExtraSmall : Theme.fontSizeSmall
                    color: Theme.secondaryColor
                    horizontalAlignment: "AlignRight"
                    width: isPortrait ? (parent.width * 0.21) - Theme.paddingSmall : parent.width * 0.16 - Theme.paddingSmall
                    topPadding: Theme.paddingSmall
                    bottomPadding: Theme.paddingSmall

                }

            }

            ListView {

                width: parent.width
                height: isPortrait ? settings.recentsShowBalances ? page.height - recentsPageHeader.height - accountBoxRow.height - balancesRow.height - balancesDividerRow.height - recentsHeaderRow.height - Theme.paddingMedium : page.height - recentsPageHeader.height - accountBoxRow.height - recentsHeaderRow.height - Theme.paddingMedium : page.height - recentsHeaderRow.height - Theme.paddingMedium
                id: recentsListView
                model: recentTransactionsModel
                spacing: Theme.paddingSmall

                delegate: Row {

                    width: parent.width - (Theme.horizontalPageMargin * 2)
                    spacing: Theme.paddingSmall
                    x: Theme.horizontalPageMargin

                    Label {

                        text: isPortrait ? dateShort : date
                        font.pixelSize: isPortrait ? Theme.fontSizeExtraSmall : Theme.fontSizeSmall
                        font.bold: uncleared
                        truncationMode: TruncationMode.Fade
                        width: isPortrait ? parent.width * 0.18 : parent.width * 0.14

                    }

                    Label {

                        text: payee
                        font.pixelSize: isPortrait ? Theme.fontSizeExtraSmall : Theme.fontSizeSmall
                        font.bold: uncleared
                        truncationMode: TruncationMode.Fade
                        width: isPortrait ? (parent.width * 0.4) - Theme.paddingSmall : (parent.width * 0.27) - Theme.paddingSmall

                    }

                    Label {

                        text: category
                        visible: isPortrait ? false : true
                        font.pixelSize: isPortrait ? Theme.fontSizeExtraSmall : Theme.fontSizeSmall
                        font.bold: uncleared
                        truncationMode: TruncationMode.Fade
                        width: parent.width * 0.27 - Theme.paddingSmall

                    }

                    Label {

                        text: inflow
                        font.pixelSize: isPortrait ? Theme.fontSizeExtraSmall : Theme.fontSizeSmall
                        font.bold: uncleared
                        truncationMode: TruncationMode.Fade
                        horizontalAlignment: "AlignRight"
                        width: isPortrait ? (parent.width * 0.21) - Theme.paddingSmall : parent.width * 0.16 - Theme.paddingSmall

                    }

                    Label {

                        text: outflow
                        font.pixelSize: isPortrait ? Theme.fontSizeExtraSmall : Theme.fontSizeSmall
                        font.bold: uncleared
                        truncationMode: TruncationMode.Fade
                        horizontalAlignment: "AlignRight"
                        width: isPortrait ? (parent.width * 0.21) - Theme.paddingSmall : parent.width * 0.16 - Theme.paddingSmall

                    }

                }

                VerticalScrollDecorator {

                    flickable: recentsListView

                }

            }

            Row {

                id: gapRow
                width: parent.width
                height: Theme.paddingMedium

            }

        }

    }

    Notification {

        id: unknownError
        isTransient: true
        expireTimeout: 2500
        appName: "AddBuy"

    }

    function loadRecentTransactions(url, callback) {

        var recentTransactionListFromServer = new XMLHttpRequest();

        recentTransactionListFromServer.onreadystatechange = (function(myxhr) {

            return function() {

                if (myxhr.readyState === 4) {

                    callback(myxhr); // http status errors hanlded in above code when function is called.

                }

            }

        })(recentTransactionListFromServer);

        recentTransactionListFromServer.open('GET', url);
        recentTransactionListFromServer.setRequestHeader("Content-Type", "application/json");
        recentTransactionListFromServer.setRequestHeader("Accept", "application/json");
        recentTransactionListFromServer.setRequestHeader("Authorization", "Bearer " + settings.accessKey);
        recentTransactionListFromServer.send('');

    }

}
