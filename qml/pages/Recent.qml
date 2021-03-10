import QtQuick 2.2
import Sailfish.Silica 1.0

Page {

    id: page
    allowedOrientations: Orientation.All

    ListModel {

        id: recentTransactionsModel

        ListElement {

            date: "..."; payee: "Loading..."; category: "..."; inflow: "..."; outflow: "..."; uncleared: false

        }

    }

    Component.onCompleted: {

        chosenRecentsAccount = settings.defaultAccountIndex;

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

        var l = settings.defaultAccountIndex;

        loadRecentTransactions('https://api.youneedabudget.com/v1/budgets/' + settings.defaultBudget + '/accounts/' + accountID[l] + '/transactions' + sinceDate, function (o) {

            // render YNAB's date format compatible with Qt's:
            dateFormat = dateFormat.replace(/DD/, "dd");
            dateFormat = dateFormat.replace(/YYYY/, "yyyy");

            var recentTransactionList = JSON.parse(o.responseText);
            recentTransactionsModel.clear(); // clear the existing one line

            var j = recentTransactionList.data.transactions.length; // need to flip order of recent transactions so that most recent is on top...

            for (var i = 0; i < recentTransactionList.data.transactions.length; i++) {

                j--; // ..using j.

                recentsDate[j] = Qt.formatDate(recentTransactionList.data.transactions[i].date, dateFormat);

                recentsPayee[j] = recentTransactionList.data.transactions[i].payee_name;
                recentsCategory[j] = recentTransactionList.data.transactions[i].category_name;

                if (recentTransactionList.data.transactions[i].amount >= 0) { // amount is income

                    recentsInflow[j] = currencySymbol[0] + ((recentTransactionList.data.transactions[i].amount / 1000).toFixed(2)) + currencySymbol[1];
                    recentsOutflow[j] = "";

                }

                else { // amount is expenditure, dividing by -1000 as we don't need minus sign in column

                    recentsOutflow[j] = currencySymbol[0] + ((recentTransactionList.data.transactions[i].amount / -1000).toFixed(2)) + currencySymbol[1];
                    recentsInflow[j] = "";

                }

                if (recentTransactionList.data.transactions[i].cleared === "cleared" || recentTransactionList.data.transactions[i].cleared === "reconciled") recentsUncleared[j] = false;
                else recentsUncleared[j] = true;

                // if user has chosen to list recents as oldest to newest, we can just add each one now as the order doesn't need to be reversed.
                if (settings.recentsOldToNew === true) {

                    recentTransactionsModel.append({ date: recentsDate[j], payee: recentsPayee[j], category: recentsCategory[j], inflow: recentsInflow[j], outflow: recentsOutflow[j], uncleared: recentsUncleared[j] });

                }

            }

            if (settings.recentsOldToNew === false) {

                for (var k = 0; k < recentTransactionList.data.transactions.length; k++) {

                    recentTransactionsModel.append({ date: recentsDate[k], payee: recentsPayee[k], category: recentsCategory[k], inflow: recentsInflow[k], outflow: recentsOutflow[k], uncleared: recentsUncleared[k] });

                }

            }

        });

        if (settings.recentsShowBalances) {

            loadAccountBalances('https://api.youneedabudget.com/v1/budgets/' + settings.defaultBudget + '/accounts/' + accountID[l], function (o) {

                var accountBalances = JSON.parse(o.responseText);
                var workingBalanceFigure = accountBalances.data.account.balance;
                var clearedBalanceFigure = accountBalances.data.account.cleared_balance;
                var putBackMinusSign = false;

                if (workingBalanceFigure === 0) {

                    switch (decimalPlaces) {

                    case 0:
                        workingBalance = currencySymbol[0] + "0" + currencySymbol[1];
                        break;
                    case 2:
                        workingBalance = currencySymbol[0] + "0.00" + currencySymbol[1];
                        break;
                    case 3:
                        workingBalance = currencySymbol[0] + "0.000" + currencySymbol[1];

                    }

                }

                else {

                    if (workingBalanceFigure < 0) {

                        putBackMinusSign = true;
                        workingBalanceFigure = workingBalanceFigure * -1;

                    }

                    switch (decimalPlaces) {

                        case 0:

                            workingBalance = (workingBalanceFigure / 10).toString();

                            // place group separators
                            if (workingBalance.length > 3) {

                                workingBalance = workingBalance.slice(0, (workingBalance.length - 3)) + groupSeparator + workingBalance.slice((workingBalance.length - 3), workingBalance.length);

                                if (workingBalance.length > 7) {

                                    workingBalance = workingBalance.slice(0, (workingBalance.length - 7)) + groupSeparator + workingBalance.slice((workingBalance.length - 7), workingBalance.length);

                                    if (workingBalance.length > 11) workingBalance = workingBalance.slice(0, (workingBalance.length - 11)) + groupSeparator + workingBalance.slice((workingBalance.length - 11), workingBalance.length);

                                }

                            }

                        break;

                        case 2:

                            workingBalance = (workingBalanceFigure / 10).toString();
                            workingBalance = workingBalance.slice(0, (workingBalance.length - decimalPlaces)) + decimalSeparator + workingBalance.slice((workingBalance.length - decimalPlaces), workingBalance.length);

                            // place group separators
                            if (workingBalance.length > 6) {

                                workingBalance = workingBalance.slice(0, (workingBalance.length - 6)) + groupSeparator + workingBalance.slice((workingBalance.length - 6), workingBalance.length);

                                if (workingBalance.length > 10) workingBalance = workingBalance.slice(0, (workingBalance.length - 10)) + groupSeparator + workingBalance.slice((workingBalance.length - 10), workingBalance.length);

                            }

                        break;

                        case 3:

                            workingBalance = (workingBalanceFigure).toString();
                            workingBalance = workingBalance.slice(0, (workingBalance.length - decimalPlaces)) + decimalSeparator + workingBalance.slice((workingBalance.length - decimalPlaces), workingBalance.length);

                            // place group separators
                            if (workingBalance.length > 7) {

                                workingBalance = workingBalance.slice(0, (workingBalance.length - 7)) + groupSeparator + workingBalance.slice((workingBalance.length - 7), workingBalance.length);

                                if (workingBalance.length > 11) workingBalance = workingBalance.slice(0, (workingBalance.length - 11)) + groupSeparator + workingBalance.slice((workingBalance.length - 11), workingBalance.length);

                            }

                    }

                    if (putBackMinusSign) workingBalance = "-" + currencySymbol[0] + workingBalance + currencySymbol[1];
                    else workingBalance = currencySymbol[0] + workingBalance + currencySymbol[1];
                    putBackMinusSign = false;

                }

                if (clearedBalanceFigure === 0) {

                    switch (decimalPlaces) {

                    case 0:
                        clearedBalance = currencySymbol[0] + "0" + currencySymbol[1];
                        break;
                    case 2:
                        clearedBalance = currencySymbol[0] + "0.00" + currencySymbol[1];
                        break;
                    case 3:
                        clearedBalance = currencySymbol[0] + "0.000" + currencySymbol[1];

                    }

                }

                else {

                    if (clearedBalanceFigure < 0) {

                        putBackMinusSign = true;
                        clearedBalanceFigure = clearedBalanceFigure * -1;

                    }

                    switch (decimalPlaces) {

                        case 0:

                            clearedBalance = (clearedBalanceFigure / 10).toString();

                            // place group separators
                            if (clearedBalance.length > 3) {

                                clearedBalance = clearedBalance.slice(0, (clearedBalance.length - 3)) + groupSeparator + clearedBalance.slice((clearedBalance.length - 3), clearedBalance.length);

                                if (clearedBalance.length > 7) {

                                    clearedBalance = clearedBalance.slice(0, (clearedBalance.length - 7)) + groupSeparator + clearedBalance.slice((clearedBalance.length - 7), clearedBalance.length);

                                    if (clearedBalance.length > 11) clearedBalance = clearedBalance.slice(0, (clearedBalance.length - 11)) + groupSeparator + clearedBalance.slice((clearedBalance.length - 11), clearedBalance.length);

                                }

                            }

                        break;

                        case 2:

                            clearedBalance = (clearedBalanceFigure / 10).toString();
                            clearedBalance = clearedBalance.slice(0, (clearedBalance.length - decimalPlaces)) + decimalSeparator + clearedBalance.slice((clearedBalance.length - decimalPlaces), clearedBalance.length);

                            // place group separators
                            if (clearedBalance.length > 6) {

                                clearedBalance = clearedBalance.slice(0, (clearedBalance.length - 6)) + groupSeparator + clearedBalance.slice((clearedBalance.length - 6), clearedBalance.length);

                                if (clearedBalance.length > 10) clearedBalance = clearedBalance.slice(0, (clearedBalance.length - 10)) + groupSeparator + clearedBalance.slice((clearedBalance.length - 10), clearedBalance.length);

                            }

                        break;

                        case 3:

                            clearedBalance = (clearedBalanceFigure).toString();
                            clearedBalance = clearedBalance.slice(0, (clearedBalance.length - decimalPlaces)) + decimalSeparator + clearedBalance.slice((clearedBalance.length - decimalPlaces), clearedBalance.length);

                            // place group separators
                            if (clearedBalance.length > 7) {

                                clearedBalance = clearedBalance.slice(0, (clearedBalance.length - 7)) + groupSeparator + clearedBalance.slice((clearedBalance.length - 7), clearedBalance.length);

                                if (clearedBalance.length > 11) clearedBalance = clearedBalance.slice(0, (clearedBalance.length - 11)) + groupSeparator + clearedBalance.slice((clearedBalance.length - 11), clearedBalance.length);

                            }

                    }

                    if (putBackMinusSign) clearedBalance = "-" + currencySymbol[0] + clearedBalance + currencySymbol[1];
                    else clearedBalance = currencySymbol[0] + clearedBalance + currencySymbol[1];

                }

            });

        }

        recentsListView.forceLayout();

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

                    label: "Account"
                    id: recentAccountBox
                    currentIndex: settings.defaultAccountIndex

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
                                            var recentTransactionList = JSON.parse(o.responseText);
                                            recentTransactionsModel.clear();

                                            var j = recentTransactionList.data.transactions.length;

                                            for (var i = 0; i < recentTransactionList.data.transactions.length; i++) {

                                                j--;

                                                recentsDate[j] = Qt.formatDate(recentTransactionList.data.transactions[i].date, dateFormat);
                                                recentsPayee[j] = recentTransactionList.data.transactions[i].payee_name;
                                                recentsCategory[j] = recentTransactionList.data.transactions[i].category_name;

                                                if (recentTransactionList.data.transactions[i].amount >= 0) {

                                                    recentsInflow[j] = currencySymbol[0] + ((recentTransactionList.data.transactions[i].amount / 1000).toFixed(2)) + currencySymbol[1];
                                                    recentsOutflow[j] = "";

                                                }

                                                else {

                                                    recentsOutflow[j] = currencySymbol[0] + ((recentTransactionList.data.transactions[i].amount / -1000).toFixed(2)) + currencySymbol[1];
                                                    recentsInflow[j] = "";

                                                }

                                                if (recentTransactionList.data.transactions[i].cleared === "cleared" || recentTransactionList.data.transactions[i].cleared === "reconciled") recentsUncleared[j] = false;
                                                else recentsUncleared[j] = true;

                                                if (settings.recentsOldToNew === true) {

                                                    recentTransactionsModel.append({ date: recentsDate[j], payee: recentsPayee[j], category: recentsCategory[j], inflow: recentsInflow[j], outflow: recentsOutflow[j], uncleared: recentsUncleared[j] });

                                                }

                                            }

                                            if (settings.recentsOldToNew === false) {

                                                for (var k = 0; k < recentTransactionList.data.transactions.length; k++) {

                                                    recentTransactionsModel.append({ date: recentsDate[k], payee: recentsPayee[k], category: recentsCategory[k], inflow: recentsInflow[k], outflow: recentsOutflow[k], uncleared: recentsUncleared[k] });

                                                }

                                            }

                                        });

                                        recentsListView.forceLayout();

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
                x: Theme.paddingSmall * 2.5
                visible: isPortrait ? settings.recentsShowBalances ? true : false : false

                Component.onCompleted: {

                    if (currencySymbol[4].length > 1 || workingBalance.length > 8 || clearedBalance.length > 8) {

                        clearedBalanceLabel.text = "Cleared:";
                        clearedBalanceLabel.width = parent.width * 0.2 - (Theme.paddingSmall * 2);
                        clearedBalanceFigureLabel.width = parent.width * 0.3 - (Theme.paddingSmall * 5);
                        workingBalanceLabel.text = "Working:";
                        workingBalanceLabel.width = parent.width * 0.2 - (Theme.paddingSmall * 5);
                        workingBalanceFigureLabel.width = parent.width * 0.3 - (Theme.paddingSmall * 2);

                    }

                }

                Label {

                    id: clearedBalanceLabel
                    width: parent.width * 0.3 - (Theme.paddingSmall * 2)
                    text: "Cleared Balance:"
                    font.pixelSize: Theme.fontSizeExtraSmall
                    bottomPadding: Theme.paddingMedium

                }

                Label {

                    id: clearedBalanceFigureLabel
                    width: parent.width * 0.2 - (Theme.paddingSmall * 5)
                    horizontalAlignment: Text.AlignRight
                    text: clearedBalance
                    font.pixelSize: Theme.fontSizeExtraSmall
                    bottomPadding: Theme.paddingMedium

                }

                Label {

                    text: " | "
                    width: Theme.paddingSmall * 5
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: Theme.fontSizeExtraSmall
                    bottomPadding: Theme.paddingMedium

                }

                Label {

                    id: workingBalanceLabel
                    width: parent.width * 0.3 - (Theme.paddingSmall * 5)
                    text: "Working Balance:"
                    font.pixelSize: Theme.fontSizeExtraSmall
                    bottomPadding: Theme.paddingMedium

                }

                Label {

                    id: workingBalanceFigureLabel
                    width: parent.width * 0.2 - (Theme.paddingSmall * 2)
                    horizontalAlignment: Text.AlignRight
                    text: workingBalance
                    font.pixelSize: Theme.fontSizeExtraSmall
                    bottomPadding: Theme.paddingMedium

                }

            }

            Row {

                id: balancesDividerRow
                width: parent.width
                x: Theme.paddingSmall
                visible: isPortrait ? settings.recentsShowBalances ? true : false : false

                Separator {

                    horizontalAlignment: Qt.AlignHCenter
                    width: parent.width - (Theme.paddingSmall * 2)
                    primaryColor: Theme.primaryColor

                }

            }

            Row {

                width: parent.width
                spacing: Theme.paddingSmall
                id: recentsHeaderRow
                x: isPortrait ?  Theme.paddingSmall * 2.5 : Theme.paddingSmall * 3

                Label {

                    text: "Date"
                    font.pixelSize: isPortrait ? Theme.fontSizeExtraSmall : Theme.fontSizeSmall
                    color: Theme.secondaryColor
                    width: isPortrait ? (parent.width * 0.22) - (Theme.paddingSmall * 2) : (parent.width * 0.16) - (Theme.paddingSmall * 2)
                    topPadding: Theme.paddingSmall
                    bottomPadding: Theme.paddingSmall

                }

                Label {

                    text: "Payee"
                    font.pixelSize: isPortrait ? Theme.fontSizeExtraSmall : Theme.fontSizeSmall
                    color: Theme.secondaryColor
                    width: isPortrait ? (parent.width * 0.38) - (Theme.paddingSmall * 2) : (parent.width * 0.28) - (Theme.paddingSmall * 2)
                    topPadding: Theme.paddingSmall
                    bottomPadding: Theme.paddingSmall

                }

                Label {

                    text: "Category"
                    visible: isPortrait ? false : true
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.secondaryColor
                    width: parent.width * 0.28 - Theme.paddingSmall * 2
                    topPadding: Theme.paddingSmall
                    bottomPadding: Theme.paddingSmall

                }

                Label {

                    text: "Inflow"
                    font.pixelSize: isPortrait ? Theme.fontSizeExtraSmall : Theme.fontSizeSmall
                    color: Theme.secondaryColor
                    horizontalAlignment: "AlignRight"
                    width: isPortrait ? (parent.width * 0.2) - (Theme.paddingSmall * 2) : (parent.width * 0.14) - (Theme.paddingSmall * 2)
                    topPadding: Theme.paddingSmall
                    bottomPadding: Theme.paddingSmall

                }

                Label {

                    text: "Outflow"
                    font.pixelSize: isPortrait ? Theme.fontSizeExtraSmall : Theme.fontSizeSmall
                    color: Theme.secondaryColor
                    horizontalAlignment: "AlignRight"
                    width: isPortrait ? (parent.width * 0.2) - (Theme.paddingSmall * 2) : (parent.width * 0.14) - (Theme.paddingSmall * 2)
                    topPadding: Theme.paddingSmall
                    bottomPadding: Theme.paddingSmall

                }

            }

            ListView {

                width: parent.width
                height: isPortrait ? settings.recentsShowBalances ? page.height - recentsPageHeader.height - accountBoxRow.height - balancesRow.height - balancesDividerRow.height - recentsHeaderRow.height - Theme.paddingMedium : page.height - recentsPageHeader.height - accountBoxRow.height - recentsHeaderRow.height - Theme.paddingMedium : page.height - recentsHeaderRow.height - Theme.paddingMedium
                id: recentsListView
                model: recentTransactionsModel
                spacing: isPortrait ? Theme.paddingSmall : Theme.paddingSmall
                VerticalScrollDecorator{flickable: recentsListView}

                delegate: Row {

                    width: parent.width
                    spacing: Theme.paddingSmall
                    x: isPortrait ? Theme.paddingSmall * 2.5 : Theme.paddingSmall * 3

                    Label {

                        text: date
                        font.pixelSize: isPortrait ? Theme.fontSizeExtraSmall : Theme.fontSizeSmall
                        font.bold: uncleared
                        truncationMode: TruncationMode.Fade
                        width: isPortrait ? (parent.width * 0.22) - (Theme.paddingSmall * 2) : (parent.width * 0.16) - (Theme.paddingSmall * 2)

                    }

                    Label {

                        text: payee
                        font.pixelSize: isPortrait ? Theme.fontSizeExtraSmall : Theme.fontSizeSmall
                        font.bold: uncleared
                        truncationMode: TruncationMode.Fade
                        width: isPortrait ? (parent.width * 0.38) - (Theme.paddingSmall * 2) : (parent.width * 0.28) - (Theme.paddingSmall * 2)

                    }

                    Label {

                        text: category
                        visible: isPortrait ? false : true
                        font.pixelSize: isPortrait ? Theme.fontSizeExtraSmall : Theme.fontSizeSmall
                        font.bold: uncleared
                        truncationMode: TruncationMode.Fade
                        width: parent.width * 0.28 - Theme.paddingSmall * 2

                    }

                    Label {

                        text: inflow
                        font.pixelSize: isPortrait ? Theme.fontSizeExtraSmall : Theme.fontSizeSmall
                        font.bold: uncleared
                        truncationMode: TruncationMode.Fade
                        horizontalAlignment: "AlignRight"
                        width: isPortrait ? (parent.width * 0.2) - (Theme.paddingSmall * 2) : (parent.width * 0.14) - (Theme.paddingSmall * 2)

                    }

                    Label {

                        text: outflow
                        font.pixelSize: isPortrait ? Theme.fontSizeExtraSmall : Theme.fontSizeSmall
                        font.bold: uncleared
                        truncationMode: TruncationMode.Fade
                        horizontalAlignment: "AlignRight"
                        width: isPortrait ? (parent.width * 0.2) - (Theme.paddingSmall * 2) : (parent.width * 0.14) - (Theme.paddingSmall * 2)

                    }

                }

            }

        }

    }

    function loadRecentTransactions(url, callback) {

        var recentTransactionListFromServer = new XMLHttpRequest();

        recentTransactionListFromServer.onreadystatechange = (function(myxhr) {

            return function() {

                if (myxhr.readyState === 4) {

                    callback(myxhr);

                    if (recentTransactionListFromServer.status === 200) {

                        // Transactions should load without any problems.

                    }

                    else {

                        // Recent Transactions gather attempt unsuccessful. Need response code and error handling.

                    }

                }

            }

        })(recentTransactionListFromServer);

        recentTransactionListFromServer.open('GET', url);
        recentTransactionListFromServer.setRequestHeader("Content-Type", "application/json");
        recentTransactionListFromServer.setRequestHeader("Accept", "application/json");
        recentTransactionListFromServer.setRequestHeader("Authorization", "Bearer " + settings.accessKey);
        recentTransactionListFromServer.send('');

    }

    function loadAccountBalances(url, callback) {

        var accountBalancesFromServer = new XMLHttpRequest();

        accountBalancesFromServer.onreadystatechange = (function(myxhr) {

            return function() {

                if (myxhr.readyState === 4) {

                    callback(myxhr);

                    if (accountBalancesFromServer.status === 200) {

                        // Account balances gathered successfully

                    }

                    else {

                        // Need response code and error handling.

                    }

                }

            }

        })(accountBalancesFromServer);

        accountBalancesFromServer.open('GET', url);
        accountBalancesFromServer.setRequestHeader("Content-Type", "application/json");
        accountBalancesFromServer.setRequestHeader("Accept", "application/json");
        accountBalancesFromServer.setRequestHeader("Authorization", "Bearer " + settings.accessKey);
        accountBalancesFromServer.send('');

    }

}
