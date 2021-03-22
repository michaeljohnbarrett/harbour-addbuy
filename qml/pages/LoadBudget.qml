import QtQuick 2.2
import Sailfish.Silica 1.0
import Nemo.Configuration 1.0

Page {

    id: page
    allowedOrientations: Orientation.PortraitMask
    property bool firstRound: true

    Component.onCompleted: {

        if (settings.accessKey === "AccessKeyHere") {

            otherElements.visible = false;
            regularBudgetLoading.visible = true;
            statusLabel.text = "No Access";
            statusLabel.verticalAlignment = "AlignBottom";
            appTitleLabel.color = "gray";
            appVersionLabel.color = "gray";
            statusLabel.color = "red";
            networkErrorLabel.font.pixelSize = Theme.fontSizeSmall;
            networkErrorLabel.text = "This is a developer-only release that requires the addition of the user's PAK to the 'accessKey' property on 'harbour-addbuy.qml'";
            networkErrorLabel.visible = true;

        }

        else {

            if (settings.defaultBudget === "notYetSetup") {

                otherElements.visible = true;
                loadingDataBusy.running = true;

                loadBudgetList('https://api.youneedabudget.com/v1/budgets', function (o) {

                    var budgetList = JSON.parse(o.responseText);

                    budgetsModel.clear();

                    for (var i = 0; i < budgetList.data.budgets.length; i++) {

                        budgetName[i] = budgetList.data.budgets[i].name;
                        budgetID[i] = budgetList.data.budgets[i].id;

                        budgetsModel.append({"title": budgetName[i], "uuid": budgetID[i]});

                    }

                    loadingDataBusy.running = false;
                    budgetListMenu.enabled = true;

                });

            }

            else {

                loadData();

            }

        }

    }

    SilicaListView {

        anchors.fill: parent
        visible: false
        id: regularBudgetLoading

        Column {

            id: column
            spacing: Theme.paddingMedium
            width: parent.width
            height: parent.height * 0.9

            Row {

                height: parent.height * 0.3
                width: parent.width

                Label {

                    id: appTitleLabel
                    text: "AddBuy for YNAB"
                    font.pixelSize: Theme.fontSizeHuge
                    width: parent.width
                    height: parent.height
                    horizontalAlignment: "AlignHCenter"
                    verticalAlignment: "AlignBottom"
                    bottomPadding: 0

                }

            }

            Row {

                height: parent.height * 0.1
                width: parent.width

                Label {

                    id: appVersionLabel
                    text: "v0.1"
                    font.pixelSize: Theme.fontSizeMedium
                    color: Theme.secondaryColor
                    width: parent.width
                    height: parent.height
                    horizontalAlignment: "AlignHCenter"
                    verticalAlignment: "AlignTop"
                    topPadding: 0

                }

            }

            Row {

                height: parent.height * 0.3
                width: parent.width

                Label {

                    id: statusLabel
                    width: parent.width
                    height: parent.height
                    text: "Loading Budget Data."
                    font.pixelSize: Theme.fontSizeLarge
                    horizontalAlignment: "AlignHCenter"
                    verticalAlignment: "AlignVCenter"
                    color: Theme.highlightColor

                    onTextChanged: {

                        if (statusLabel.text === "Loading Budget Data.....") {

                            statusLabel.text = "Budget Ready";

                        }

                    }

                }

            }

            Row {

                height: parent.height * 0.3
                width: parent.width

                Label {

                    id: networkErrorLabel
                    width: parent.width
                    height: parent.height
                    text: "Please quit the app, check network settings, then reopen."
                    font.pixelSize: Theme.fontSizeMedium
                    horizontalAlignment: "AlignHCenter"
                    verticalAlignment: "AlignTop"
                    wrapMode: Text.WordWrap
                    color: Theme.highlightColor
                    visible: false
                    leftPadding: Theme.paddingLarge
                    rightPadding: Theme.paddingLarge

                }

            }

        }

        Timer {

            id: requestTimoutTimer
            running: false
            interval: 7000
            repeat: true

            onTriggered: {

                if (firstRound == false) {

                    statusLabel.text = "Network Timeout";
                    statusLabel.verticalAlignment = "AlignBottom";
                    appTitleLabel.color = "gray";
                    appVersionLabel.color = "gray";
                    statusLabel.color = "red";
                    networkErrorLabel.visible = true;
                    console.log("Load attempt unsuccessful.");
                    this.stop();

                }

                else {

                    statusLabel.text = "Slow Connection...";
                    console.log("Load attempt is slow.");
                    firstRound = false;

                }

            }

        }

    }

    // Possible use of OAuth will need this added.
    /*
    SilicaWebView {

        id: authorizeUser
        height: page.height * 0.6
        width: page.width
        visible: false

        anchors {

            left: parent.left
            right: parent.right
            top: parent.top

        }

        onUrlChanged: {

            // Redirect user following successful authentication etc.

        }

    }
    */

    SilicaListView {

        visible: false
        id: otherElements
        spacing: 0
        height: page.height // * 0.4  -- will possibly re-enable if webview is needed.
        width: page.width

        /* --  for use if webview/oauth are in use.
        anchors {

            top: authorizeUser.bottom
            left: parent.left
            right: parent.right

        }
        */

        anchors.fill: parent

        Column {

            height: parent.height
            width: parent.width
            id: otherElementsColumn

            Row {

                width: parent.width
                spacing: Theme.paddingLarge

                // need to place app title above this for better page layout as oauth window not present.

                Label {

                    id: pleaseAuthLabel
                    width: parent.width
                    text: "Please choose a default budget and account. These settings can be changed later."
                    font.pixelSize: Theme.fontSizeExtraSmall
                    wrapMode: Text.WordWrap
                    color: Theme.highlightColor
                    leftPadding: budgetListMenu.leftMargin
                    rightPadding: budgetListMenu.leftMargin
                    topPadding: Theme.paddingMedium
                    bottomPadding: Theme.paddingMedium
                    verticalAlignment: "AlignVCenter"

                }

            }

            Row {

                width: parent.width
                spacing: Theme.paddingSmall

                ComboBox {

                    id: budgetListMenu
                    width: parent.width
                    enabled: false
                    label: "Default Budget"

                    menu: ContextMenu {

                        id: budgetContextMenu

                        Repeater {

                            model: budgetsModel

                            MenuItem {

                                text: title

                                onClicked: {

                                    settings.defaultBudget = uuid;
                                    settings.defaultBudgetIndex = index;
                                    settings.sync();

                                    loadingDataBusy.running = true;
                                    loadAccountData('https://api.youneedabudget.com/v1/budgets/' + settings.defaultBudget + '/accounts', function (o) {

                                        var accountList = JSON.parse(o.responseText);
                                        var j = 0;

                                        accountsModel.clear();

                                        for (var i = 0; i < accountList.data.accounts.length; i++) {

                                            if (accountList.data.accounts[i].closed === false) {

                                                accountName[j] = accountList.data.accounts[i].name;
                                                accountID[j] = accountList.data.accounts[i].id;

                                                accountsModel.append({"title": accountName[j], "uuid": accountID[j]});

                                                j = j + 1;

                                            }

                                        }

                                        accountListMenu.enabled = true;
                                        requestTimoutTimer.stop();
                                        loadingDataBusy.running = false;

                                    });

                                }

                            }

                        }

                    }

                }

            }

            Row {

                id: accountListRow
                width: parent.width
                spacing: Theme.paddingSmall

                ComboBox {

                    id: accountListMenu
                    width: parent.width
                    enabled: false
                    label: "Default Account"

                    menu: ContextMenu {

                        id: accountContextMenu

                        Repeater {

                            model: accountsModel

                            MenuItem {

                                text: title

                                onClicked: {

                                    settings.defaultAccount = uuid;
                                    settings.defaultAccountIndex = index;
                                    settings.sync();

                                    continueButton.enabled = true;

                                }

                            }

                        }

                    }

                }

            }

            Row {

                width: continueButton.width
                x: (parent.width - continueButton.width) * 0.5

                Button {

                    id: continueButton
                    text: "Continue"
                    enabled: false
                    y: Theme.paddingMedium * 2

                    onClicked: {

                        pageStack.replace(Qt.resolvedUrl("LoadBudget.qml"));

                    }

                }

            }

        }

        BusyIndicator {

            id: loadingDataBusy
            size: BusyIndicatorSize.Large
            anchors.centerIn: parent
            running: false

        }

    }

    function loadData() {

        // no need for oauth etc., hiding incase of coming back from first setup
        // authorizeUser.visible = false;
        otherElements.visible = false;
        // need regular data loading page.
        regularBudgetLoading.visible = true;

        loadBudgetList('https://api.youneedabudget.com/v1/budgets', function (o) {

            var budgetList = JSON.parse(o.responseText);
            var defaultBudgetAssigned = false;

            for (var i = 0; i < budgetList.data.budgets.length; i++) {

                budgetName[i] = budgetList.data.budgets[i].name;
                budgetID[i] = budgetList.data.budgets[i].id;

                // Determine default budget in list to get correct index.
                if (budgetID[i] === settings.defaultBudget) {

                    defaultBudgetAssigned = true;
                    settings.defaultBudgetIndex = i;

                }

            }

            // If still no default, for whatever reason, first in list will be assigned default status.
            if (defaultBudgetAssigned === false) settings.defaultBudgetIndex = 0;


        });

        loadBudgetSettings('https://api.youneedabudget.com/v1/budgets/' + settings.defaultBudget + '/settings', function (o) {

            var budgetSettingsList = JSON.parse(o.responseText);
            dateFormat = budgetSettingsList.data.settings.date_format.format;
            currencySymbol[4] = budgetSettingsList.data.settings.currency_format.currency_symbol;
            symbolFirst = budgetSettingsList.data.settings.currency_format.symbol_first;
            if (isRTL(currencySymbol[4])) symbolFirst = !symbolFirst;
            decimalPlaces = budgetSettingsList.data.settings.currency_format.decimal_digits;
            decimalSeparator = budgetSettingsList.data.settings.currency_format.decimal_separator;
            groupSeparator = budgetSettingsList.data.settings.currency_format.group_separator;

            if (symbolFirst) {

                currencySymbol[2] = currencySymbol[4];
                currencySymbol[3] = "";

                if (budgetSettingsList.data.settings.currency_format.display_symbol === true) {

                    currencySymbol[0] = currencySymbol[4];
                    currencySymbol[1] = "";

                }

                else {

                    currencySymbol[0] = "";
                    currencySymbol[1] = "";

                }

            }

            else {

                currencySymbol[2] = "";
                currencySymbol[3] = currencySymbol[4];

                if (budgetSettingsList.data.settings.currency_format.display_symbol === true) {

                    currencySymbol[0] = "";
                    currencySymbol[1] = currencySymbol[4];

                }

                else {

                    currencySymbol[0] = "";
                    currencySymbol[1] = "";

                }

            }

        });

        loadPayeeData('https://api.youneedabudget.com/v1/budgets/' + settings.defaultBudget + '/payees', function (o) {

            var payeeList = JSON.parse(o.responseText);

            for (var i = 0; i < payeeList.data.payees.length; i++) {

                payeeName[i] = payeeList.data.payees[i].name;
                // trying out a parallel string array of each value in uppercase to see if this can achieve case-insensitive search
                payeeNameToUpperCase[i] = payeeName[i].toUpperCase();
                payeeID[i] = payeeList.data.payees[i].id;

            }

        });

        loadCategoryData('https://api.youneedabudget.com/v1/budgets/' + settings.defaultBudget + '/categories', function (o) {

            var categoryList = JSON.parse(o.responseText);

            var k = 1; // for overall category count - first entry reserved for 'Default'
            categoryName[0] = "Default";
            categoryID[0] = "";
            budgetCategoriesModel.clear();

            for (var i = 1; i < categoryList.data.category_groups.length; i++) { // '1' instead of '0' because we skip first category group (internal)

                if (categoryList.data.category_groups[i].hidden === false && categoryList.data.category_groups[i].name !== "Hidden Categories") {

                    budgetCategoriesModel.append({ "groupName": categoryList.data.category_groups[i].name, "groupNameVis": true, "catNamesVis": false, "categories": {"name": "", "uuid": "", "budgeted": "", "activity": "", "balance": ""} });

                    for (var j = 0; j < categoryList.data.category_groups[i].categories.length; j++) {

                        if (categoryList.data.category_groups[i].categories[j].hidden === false) {

                            var getFigure = [0];
                            var categoryAmounts = ["string"];
                            getFigure[0] = categoryList.data.category_groups[i].categories[j].budgeted;
                            getFigure[1] = categoryList.data.category_groups[i].categories[j].activity;
                            getFigure[2] = categoryList.data.category_groups[i].categories[j].balance;

                            for (var l = 0; l < 3; l++) {

                                var putBackMinusSign = false;

                                if (getFigure[l] === 0) {

                                    switch (decimalPlaces) {

                                    case 0:
                                        categoryAmounts[l] = currencySymbol[0] + "0" + currencySymbol[1];
                                        break;
                                    case 2:
                                        categoryAmounts[l] = currencySymbol[0] + "0.00" + currencySymbol[1];
                                        break;
                                    case 3:
                                        categoryAmounts[l] = currencySymbol[0] + "0.000" + currencySymbol[1];

                                    }

                                }

                                else {

                                    if (getFigure[l] < 0) {

                                        putBackMinusSign = true;
                                        getFigure[l] = getFigure[l] * -1;

                                    }

                                    switch (decimalPlaces) {

                                    case 0:

                                        categoryAmounts[l] = (getFigure[l] / 10).toString();

                                        if (categoryAmounts[l].length > 3) {

                                            categoryAmounts[l] = categoryAmounts[l].slice(0, (categoryAmounts[l].length - 3)) + groupSeparator + categoryAmounts[l].slice((categoryAmounts[l].length - 3), categoryAmounts[l].length);

                                            if (categoryAmounts[l].length > 7) {

                                                categoryAmounts[l] = categoryAmounts[l].slice(0, (categoryAmounts[l].length - 7)) + groupSeparator + categoryAmounts[l].slice((categoryAmounts[l].length - 7), categoryAmounts[l].length);

                                                if (categoryAmounts[l].length > 11) categoryAmounts[l] = categoryAmounts[l].slice(0, (categoryAmounts[l].length - 11)) + groupSeparator + categoryAmounts[l].slice((categoryAmounts[l].length - 11), categoryAmounts[l].length);

                                            }

                                        }

                                        break;

                                    case 2:

                                        categoryAmounts[l] = (getFigure[l] / 10).toString();
                                        categoryAmounts[l] = categoryAmounts[l].slice(0, (categoryAmounts[l].length - decimalPlaces)) + decimalSeparator + categoryAmounts[l].slice((categoryAmounts[l].length - decimalPlaces), categoryAmounts[l].length);

                                        if (categoryAmounts[l].length > 6) {

                                            categoryAmounts[l] = categoryAmounts[l].slice(0, (categoryAmounts[l].length - 6)) + groupSeparator + categoryAmounts[l].slice((categoryAmounts[l].length - 6), categoryAmounts[l].length);

                                            if (categoryAmounts[l].length > 10) categoryAmounts[l] = categoryAmounts[l].slice(0, (categoryAmounts[l].length - 10)) + groupSeparator + categoryAmounts[l].slice((categoryAmounts[l].length - 10), categoryAmounts[l].length);

                                        }

                                        break;

                                    case 3:

                                        categoryAmounts[l] = (getFigure[l]).toString();
                                        categoryAmounts[l] = categoryAmounts[l].slice(0, (categoryAmounts[l].length - decimalPlaces)) + decimalSeparator + categoryAmounts[l].slice((categoryAmounts[l].length - decimalPlaces), categoryAmounts[l].length);

                                        if (categoryAmounts[l].length > 7) { // we know number of decimal places so group separator requirement if fixed at 8 (incl. decimal separator)

                                            categoryAmounts[l] = categoryAmounts[l].slice(0, (categoryAmounts[l].length - 7)) + groupSeparator + categoryAmounts[l].slice((categoryAmounts[l].length - 7), categoryAmounts[l].length);

                                            if (categoryAmounts[l].length > 11) categoryAmounts[l] = categoryAmounts[l].slice(0, (categoryAmounts[l].length - 11)) + groupSeparator + categoryAmounts[l].slice((categoryAmounts[l].length - 11), categoryAmounts[l].length);

                                        }

                                    }

                                    if (putBackMinusSign) categoryAmounts[l] = "-" + currencySymbol[0] + categoryAmounts[l] + currencySymbol[1];
                                    else categoryAmounts[l] = currencySymbol[0] + categoryAmounts[l] + currencySymbol[1];

                                }

                            }

                            categoryName[k] = categoryList.data.category_groups[i].categories[j].name;
                            categoryID[k] = categoryList.data.category_groups[i].categories[j].id;
                            budgetCategoriesModel.append({ "groupName": "", "groupNameVis": false, "catNamesVis": true, "categories": { "name": categoryList.data.category_groups[i].categories[j].name, "uuid": categoryList.data.category_groups[i].categories[j].id, "budgeted": categoryAmounts[0], "activity": categoryAmounts[1], "balance": categoryAmounts[2] }});
                            k++;

                        }

                    }

                }

            }

            // incase user never interacts with category choosing menu prior to saving, it'll be blank:
            categorySendReady = "category_id\": \"";

        });

        loadAccountData('https://api.youneedabudget.com/v1/budgets/' + settings.defaultBudget + '/accounts', function (o) {

            var accountList = JSON.parse(o.responseText);
            var k = settings.defaultAccount;
            var j = 0;
            var defaultAccountAssigned = false;
            accountsModel.clear();

            for (var i = 0; i < accountList.data.accounts.length; i++) {

                if (accountList.data.accounts[i].closed === false) {

                    accountName[j] = accountList.data.accounts[i].name;
                    accountID[j] = accountList.data.accounts[i].id;
                    accountClearedBal[j] = (accountList.data.accounts[i].cleared_balance / 1000).toFixed(2);
                    accountWorkingBal[j] = (accountList.data.accounts[i].uncleared_balance / 1000).toFixed(2);
                    accountsModel.append({"title": accountName[j], "uuid": accountID[j]});

                    if (accountID[j] === k) {

                        chosenAccount = j;
                        settings.defaultAccountIndex = j; // incase list of accounts has changed since last use?
                        defaultAccountAssigned = true;

                    }

                    j = j + 1;

                }

            }

            // If still no default, for whatever reason, first in list will be assigned default status.
            if (defaultAccountAssigned === false) {

                chosenAccount = 0;
                settings.defaultAccountIndex = 0;

            }

            // incase user never interacts with account choosing menu:
            accountSendReady = "account_id\": \"" + accountID[chosenAccount];

        });

    }

    function loadPayeeData(url, callback) {

        var payeeListFromServer = new XMLHttpRequest();

        payeeListFromServer.onreadystatechange = (function(myxhr) {

            return function() {

                if (myxhr.readyState === 4) {

                    callback(myxhr);

                    if (payeeListFromServer.status === 200) {

                        console.log("Payees gathered successfully.");
                        statusLabel.text = statusLabel.text + ".";
                        loadingProgress = loadingProgress + 1;

                    }

                    else {

                        console.log("Repsonse from server: " + payeeListFromServer.status);

                    }

                }

                else {

                    // Current network connection attempt status for payees.

                }

            }

        })(payeeListFromServer);

        payeeListFromServer.open('GET', url);
        payeeListFromServer.setRequestHeader("Content-Type", "application/json");
        payeeListFromServer.setRequestHeader("Accept", "application/json");
        payeeListFromServer.setRequestHeader("Authorization", "Bearer " + settings.accessKey);
        payeeListFromServer.send('');

    }

    function loadCategoryData(url, callback) {

        var categoryListFromServer = new XMLHttpRequest();

        categoryListFromServer.onreadystatechange = (function(myxhr) {

            return function() {

                if (myxhr.readyState === 4) {

                    callback(myxhr);

                    if (categoryListFromServer.status === 200) {

                        console.log("Categories gathered successfully.");
                        loadingProgress = loadingProgress + 1;
                        statusLabel.text = statusLabel.text + ".";

                    }

                    else {

                        console.log("Repsonse from server: " + categoryListFromServer.status);

                    }

                }

                else {

                    // Current network connection attempt status for categories.

                }

            }

        })(categoryListFromServer);

        categoryListFromServer.open('GET', url);
        categoryListFromServer.setRequestHeader("Content-Type", "application/json");
        categoryListFromServer.setRequestHeader("Accept", "application/json");
        categoryListFromServer.setRequestHeader("Authorization", "Bearer " + settings.accessKey);
        categoryListFromServer.send('');

    }

    function loadAccountData(url, callback) {

        var accountListFromServer = new XMLHttpRequest();

        accountListFromServer.onreadystatechange = (function(myxhr) {

            return function() {

                if (myxhr.readyState === 4) {

                    callback(myxhr);

                    if (accountListFromServer.status === 200) {

                        console.log("Accounts gathered successfully.");
                        loadingProgress = loadingProgress + 1;
                        statusLabel.text = statusLabel.text + ".";

                    }

                    else {

                        console.log("Repsonse from server: " + accountListFromServer.status);

                    }

                }

                else {

                    // Current network connection attempt status for accounts.

                }

            }

        })(accountListFromServer);

        accountListFromServer.open('GET', url);
        accountListFromServer.setRequestHeader("Content-Type", "application/json");
        accountListFromServer.setRequestHeader("Accept", "application/json");
        accountListFromServer.setRequestHeader("Authorization", "Bearer " + settings.accessKey);
        accountListFromServer.send('');

    }

    function loadBudgetList(url, callback) {

        requestTimoutTimer.start();

        var budgetListFromServer = new XMLHttpRequest();

        budgetListFromServer.onreadystatechange = (function(myxhr) {

            return function() {

                if (myxhr.readyState === 4) {

                    callback(myxhr);

                    if (budgetListFromServer.status === 200) {

                        console.log("Budgets gathered successfully.");
                        loadingProgress = loadingProgress + 1;
                        statusLabel.text = statusLabel.text + ".";

                    }

                    else {

                        console.log("Repsonse from server: " + budgetListFromServer.status);

                    }

                }

                else {

                    // Current network connection attempt status for categories.

                }

            }

        })(budgetListFromServer);

        budgetListFromServer.open('GET', url);
        budgetListFromServer.setRequestHeader("Content-Type", "application/json");
        budgetListFromServer.setRequestHeader("Accept", "application/json");
        budgetListFromServer.setRequestHeader("Authorization", "Bearer " + settings.accessKey);
        budgetListFromServer.send('');

    }

    function isRTL(s) {

        // courtesy of StackOverflow user vsync -
        // https://stackoverflow.com/questions/12006095/javascript-how-to-check-if-character-is-rtl/14824756#14824756

        var ltrChars    = 'A-Za-z\u00C0-\u00D6\u00D8-\u00F6\u00F8-\u02B8\u0300-\u0590\u0800-\u1FFF'+'\u2C00-\uFB1C\uFDFE-\uFE6F\uFEFD-\uFFFF',
            rtlChars    = '\u0591-\u07FF\uFB1D-\uFDFD\uFE70-\uFEFC',
            rtlDirCheck = new RegExp('^[^'+ltrChars+']*['+rtlChars+']');
        return rtlDirCheck.test(s);

    }

}
