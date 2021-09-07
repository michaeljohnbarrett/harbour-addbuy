import QtQuick 2.2
import Sailfish.Silica 1.0
import Nemo.Configuration 1.0
import Nemo.Notifications 1.0
import NetworkPostAccess 1.0

Page {

    id: page
    allowedOrientations: Orientation.PortraitMask
    property bool firstRound: true

    Component.onCompleted: {

        if (settings.accessKey === "") {

            authorizeUser.visible = true;
            authorizeUser.url = "https://app.youneedabudget.com/oauth/authorize?client_id=0000000000000000000000-CLIENTID-GOES-HERE-0000000000000000000000&redirect_uri=https://mjbdev.net/addbuy/oauthSuccess.html&response_type=token";

        }

        else loadData();

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
                    text: "v0.2"
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
                    text: qsTr("Loading Budget Data.")
                    font.pixelSize: Theme.fontSizeLarge
                    horizontalAlignment: "AlignHCenter"
                    verticalAlignment: "AlignVCenter"
                    color: Theme.highlightColor

                }

            }

            Row {

                height: parent.height * 0.3
                width: parent.width

                Label {

                    id: networkErrorLabel
                    width: parent.width
                    height: parent.height
                    text: qsTr("Please quit the app, check network settings, then reopen.")
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

            id: requestTimeoutTimer
            running: false
            interval: 7000
            repeat: true

            onTriggered: {

                if (firstRound == false) {

                    statusLabel.text = qsTr("Network Timeout");
                    statusLabel.verticalAlignment = "AlignBottom";
                    appTitleLabel.color = "gray";
                    appVersionLabel.color = "gray";
                    statusLabel.color = Theme.errorColor;
                    networkErrorLabel.visible = true;
                    this.stop();

                }

                else {

                    statusLabel.text = qsTr("Slow Connection...");
                    firstRound = false;

                }

            }

        }

    }

    SilicaWebView {

        id: authorizeUser
        height: otherElements.visible ? page.height * 0.55 : page.height
        width: page.width
        visible: false
        //_cookiesEnabled: settings.forceForgetSignIn ? false : true  <-- could not get web page to load with this property set either way.

        anchors {

            left: parent.left
            right: parent.right
            top: parent.top

        }

        header: PageHeader {

            id: webViewHeader
            title: qsTr("Authorize AddBuy")

        }

        onUrlChanged: {

            var urlString = url.toString();

            if (urlString.indexOf("https://mjbdev.net/addbuy/oauthSuccess.html") === 0) {

                var accessToken = urlString.slice((urlString.indexOf("access_token=") + 13), (urlString.indexOf("access_token=") + 77));

                loadingDataBusy.running = true;
                settings.accessKey = accessToken;
                settings.sync();

                loadBudgetList('https://api.youneedabudget.com/v1/budgets', function (o) {

                    var budgetList = JSON.parse(o.responseText);
                    var defaultBudgetMatched = false;
                    budgetsModel.clear();

                    for (var i = 0; i < budgetList.data.budgets.length; i++) {

                        budgetName[i] = budgetList.data.budgets[i].name;
                        budgetID[i] = budgetList.data.budgets[i].id;
                        budgetsModel.append({"title": budgetName[i], "uuid": budgetID[i]});

                        if (budgetID[i] === settings.defaultBudget) {

                            defaultBudgetMatched = true;
                            settings.defaultBudgetIndex = i;
                            settings.sync();

                        }

                    }

                    if (defaultBudgetMatched) {

                        loadingProgress = 0;
                        authorizeUser.visible = false;
                        otherElements.visible = false;
                        regularBudgetLoading.visible = true;
                        finishLoadingData();

                    }

                    else {

                        loadingDataBusy.running = false;
                        chooseDefaultsRow.visible = true;
                        budgetListMenu.enabled = true;

                    }

                });

            }

        }

    }

    SilicaListView {

        visible: false
        id: otherElements
        spacing: 0
        height: page.height * 0.35
        width: page.width

        anchors {

            top: authorizeUser.bottom
            left: parent.left
            right: parent.right

        }

        Column {

            height: parent.height
            width: parent.width

            Row {

                width: parent.width
                id: chooseDefaultsRow
                visible: false

                Column {

                    width: parent.width
                    id: chooseDefaultsColumn

                    Row {

                        width: parent.width
                        spacing: Theme.paddingLarge

                        Label {

                            id: pleaseAuthLabel
                            width: parent.width
                            text: qsTr("Please choose a default budget and account. These settings can be changed later.")
                            font.pixelSize: Theme.fontSizeExtraSmall
                            wrapMode: Text.WordWrap
                            color: Theme.highlightColor
                            leftPadding: budgetListMenu.leftMargin
                            rightPadding: budgetListMenu.leftMargin
                            topPadding: Theme.paddingMedium
                            bottomPadding: Theme.paddingMedium
                            verticalAlignment: "AlignVCenter"
                            enabled: false

                        }

                    }

                    Row {

                        width: parent.width
                        spacing: Theme.paddingSmall

                        ComboBox {

                            id: budgetListMenu
                            width: parent.width
                            enabled: false
                            label: qsTr("Default Budget")

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

                                                if (o.status === 200) {

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
                                                    requestTimeoutTimer.stop();
                                                    loadingDataBusy.running = false;

                                                }

                                                else if (o.status === 401 || o.status === 403) {

                                                    needNewKey(); // unlikely but could've waited two hours?

                                                }

                                                else {

                                                    loadBudgetNotification.previewSummary = "Error gathering accounts."
                                                    loadBudgetNotification.publish();

                                                }

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
                            label: qsTr("Default Account")

                            menu: ContextMenu {

                                id: accountContextMenu

                                Repeater {

                                    model: accountsModel

                                    MenuItem {

                                        text: title

                                        onClicked: {

                                            settings.defaultAccount = uuid;
                                            settings.defaultAccountIndex = index;
                                            settings.setupComplete = true
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
                            text: qsTr("Continue")
                            enabled: false
                            y: Theme.paddingMedium * 2

                            onClicked: {

                                loadingProgress = 0;
                                pageStack.replace(Qt.resolvedUrl("LoadBudget.qml"));

                            }

                        }

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

        Notification {

            id: loadBudgetNotification
            isTransient: true
            expireTimeout: 1500
            appName: "AddBuy"

        }

    }

    function loadData() {

        otherElements.visible = false;
        regularBudgetLoading.visible = true;

        loadBudgetList('https://api.youneedabudget.com/v1/budgets', function width(o) {

            if (o.status === 200) {

                var budgetList = JSON.parse(o.responseText);
                var defaultBudgetMatched = false;

                for (var i = 0; i < budgetList.data.budgets.length; i++) {

                    budgetName[i] = budgetList.data.budgets[i].name;
                    budgetID[i] = budgetList.data.budgets[i].id;

                    // Determine default budget in list to get correct index.
                    if (budgetID[i] === settings.defaultBudget) {

                        defaultBudgetMatched = true;
                        settings.defaultBudgetIndex = i;
                        settings.sync();

                    }

                }

                // If still no default, for whatever reason (budget deleted since), first in list will be assigned default status.
                if (defaultBudgetMatched === false) {

                    settings.defaultBudgetIndex = 0;
                    settings.defaultBudget = budgetID[0];
                    settings.sync();

                }

                finishLoadingData();

            }

            else if (o.status === 401 || o.status === 403) {

                requestTimeoutTimer.stop();
                needNewKey();

            }
/*
            else if (o.status === 503) {

                // need to add improved way to account for maintenance periods etc.
                requestTimeoutTimer.stop();
                needNewKey();

            }
*/
            else {

                requestTimeoutTimer.stop();
                needNewKey();

            }

        });

    }

    function finishLoadingData() {

        loadBudgetSettings('https://api.youneedabudget.com/v1/budgets/' + settings.defaultBudget + '/settings', function (o) {

            var budgetSettingsList = JSON.parse(o.responseText);

            if (o.status === 200) {

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

                loadingProgress = loadingProgress + 1;
                statusLabel.text = statusLabel.text + ".";

            }

            else if (o.status === 401 || o.status === 403) {

                requestTimeoutTimer.stop();
                needNewKey();

            }
/*
            else if (o.status === 503) {

                // account for maintenance periods etc. redirect to login for now where notice should show on page?
                requestTimeoutTimer.stop();
                needNewKey();

            }
*/
            else {

                requestTimeoutTimer.stop();
                needNewKey();

            }

        });

        loadPayeeData('https://api.youneedabudget.com/v1/budgets/' + settings.defaultBudget + '/payees', function (o) {

            var payeeList = JSON.parse(o.responseText);

            if (o.status === 200) {

                for (var i = 0; i < payeeList.data.payees.length; i++) {

                    payeeName[i] = payeeList.data.payees[i].name;
                    payeeNameToUpperCase[i] = payeeName[i].toUpperCase();
                    payeeID[i] = payeeList.data.payees[i].id;

                }

                statusLabel.text = statusLabel.text + ".";
                loadingProgress = loadingProgress + 1;

            }

            else if (o.status === 401 || o.status === 403) {

                requestTimeoutTimer.stop();
                needNewKey();

            }
/*
            else if (o.status === 503) {

                // account for maintenance periods
                requestTimeoutTimer.stop();
                needNewKey();

            }
*/
            else {

                requestTimeoutTimer.stop();
                needNewKey();

            }

        });

        loadAccountData('https://api.youneedabudget.com/v1/budgets/' + settings.defaultBudget + '/accounts', function (o) {

            var accountList = JSON.parse(o.responseText);

            if (o.status === 200) {

                var k = settings.defaultAccount;
                var j = 0;
                var l = 0;
                var defaultAccountAssigned = false;
                accountsModel.clear();
                coverBalComboModel.clear();

                for (var i = 0; i < accountList.data.accounts.length; i++) {

                    if (accountList.data.accounts[i].closed === false) {

                        accountName[j] = accountList.data.accounts[i].name;
                        accountID[j] = accountList.data.accounts[i].id;
                        accountClearedBal[j] = (accountList.data.accounts[i].cleared_balance / 1000).toFixed(2);
                        accountWorkingBal[j] = (accountList.data.accounts[i].uncleared_balance / 1000).toFixed(2);
                        accountsModel.append({"title": accountName[j], "uuid": accountID[j]});

                        coverBalComboModel.append({title: "Working " + accountName[j], uuid: accountID[j], account: true, cleared: false});
                        coverBalComboModel.append({title: "Cleared " + accountName[j], uuid: accountID[j], account: true, cleared: true});

                        if (accountID[j] === k) {

                            chosenAccount = j;
                            settings.defaultAccountIndex = j; // incase list of accounts has changed since last use?
                            settings.sync();
                            defaultAccountAssigned = true;

                        }

                        j = j + 1;
                        l = l + 1;

                    }

                }

                // If still no default, for whatever reason (e.g. account deleted since), first in list will be assigned default status.
                if (defaultAccountAssigned === false) {

                    chosenAccount = 0;
                    settings.defaultAccountIndex = 0;
                    settings.defaultAccount = accountID[0];
                    settings.sync();

                }

                // incase user never interacts with account-choosing menu:
                accountSendReady = "account_id\": \"" + accountID[chosenAccount];
                loadingProgress = loadingProgress + 1;
                statusLabel.text = statusLabel.text + ".";

            }

            else if (o.status === 401 || o.status === 403) {

                requestTimeoutTimer.stop();
                needNewKey();

            }
/*
            else if (o.status === 503) {

                // account for maintenance periods etc. redirect to login for now where notice should show on page?
                requestTimeoutTimer.stop();
                needNewKey();

            }
*/
            else {

                requestTimeoutTimer.stop();
                needNewKey();

            }

            // need to have loadCategoryData attatched to the end of loadAccountData in order for coverBalComboModel to be put together correctly.
            loadCategoryData('https://api.youneedabudget.com/v1/budgets/' + settings.defaultBudget + '/categories', function (o) {

                var categoryList = JSON.parse(o.responseText);

                if (o.status === 200) {

                    var k = 1; // for overall category count - first entry reserved for 'Default'
                    categoryName[0] = "Default";
                    categoryID[0] = "";
                    budgetCategoriesModel.clear();

                    // gather ID for Inflow category
                    inflowCatId = categoryList.data.category_groups[0].categories[1].id;

                    for (var i = 1; i < categoryList.data.category_groups.length; i++) { // '1' instead of '0' because we skip first category group (internal)

                        if (categoryList.data.category_groups[i].hidden === false && categoryList.data.category_groups[i].name !== "Hidden Categories") {

                            budgetCategoriesModel.append({ "groupName": categoryList.data.category_groups[i].name, "groupNameVis": true, "catNamesVis": false, "categories": {"name": "", "uuid": "", "budgeted": "", "activity": "", "balance": ""} });

                            for (var j = 0; j < categoryList.data.category_groups[i].categories.length; j++) {

                                if (categoryList.data.category_groups[i].categories[j].hidden === false) {

                                    var categoryAmounts = ["string"];
                                    categoryAmounts[0] = formatFigure(categoryList.data.category_groups[i].categories[j].budgeted);
                                    categoryAmounts[1] = formatFigure(categoryList.data.category_groups[i].categories[j].activity);
                                    categoryAmounts[2] = formatFigure(categoryList.data.category_groups[i].categories[j].balance);

                                    categoryName[k] = categoryList.data.category_groups[i].categories[j].name;
                                    categoryID[k] = categoryList.data.category_groups[i].categories[j].id;
                                    coverBalComboList[k+1+(accountName.length*2)] = categoryList.data.category_groups[i].categories[j].name;
                                    coverBalComboModel.append({title: categoryList.data.category_groups[i].categories[j].name, uuid: categoryList.data.category_groups[i].categories[j].id, account: false, cleared: false});
                                    budgetCategoriesModel.append({ "groupName": "", "groupNameVis": false, "catNamesVis": true, "categories": { "name": categoryList.data.category_groups[i].categories[j].name, "uuid": categoryList.data.category_groups[i].categories[j].id, "budgeted": categoryAmounts[0], "activity": categoryAmounts[1], "balance": categoryAmounts[2] }});
                                    k++;

                                }

                            }

                        }

                    }

                    // incase user never interacts with category menu prior to saving, it'll be blank/default:
                    categorySendReady = "";
                    statusLabel.text = statusLabel.text + ".";
                    loadingProgress = loadingProgress + 1;

                }

                else if (o.status === 401 || o.status === 403) {

                    requestTimeoutTimer.stop();
                    needNewKey();

                }
/* -- doing the same thing as 'else' for now at least.
                else if (o.status === 503) {

                    // account for maintenance periods etc. redirect to login for now where notice should show on page?
                    requestTimeoutTimer.stop();
                    needNewKey();

                }
*/
                else {

                    requestTimeoutTimer.stop();
                    needNewKey();

                }

            });

        });

    }

    function loadPayeeData(url, callback) {

        var payeeListFromServer = new XMLHttpRequest();

        payeeListFromServer.onreadystatechange = (function(myxhr) {

            return function() {

                if (myxhr.readyState === 4) {

                    callback(myxhr);

                    // http status codes handled on other side

                }

            }

        })(payeeListFromServer);

        payeeListFromServer.open('GET', url);
        payeeListFromServer.setRequestHeader("Content-Type", "application/json");
        payeeListFromServer.setRequestHeader("Accept", "application/json");
        payeeListFromServer.setRequestHeader("Authorization", "Bearer " + settings.accessKey);
        payeeListFromServer.send('');

    }

    function loadAccountData(url, callback) {

        var accountListFromServer = new XMLHttpRequest();

        accountListFromServer.onreadystatechange = (function(myxhr) {

            return function() {

                if (myxhr.readyState === 4) {

                    callback(myxhr);

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

        requestTimeoutTimer.start();

        var budgetListFromServer = new XMLHttpRequest();

        budgetListFromServer.onreadystatechange = (function(myxhr) {

            return function() {

                if (myxhr.readyState === 4) {

                    callback(myxhr);

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

        var ltrChars = 'A-Za-z\u00C0-\u00D6\u00D8-\u00F6\u00F8-\u02B8\u0300-\u0590\u0800-\u1FFF'+'\u2C00-\uFB1C\uFDFE-\uFE6F\uFEFD-\uFFFF',
            rtlChars = '\u0591-\u07FF\uFB1D-\uFDFD\uFE70-\uFEFC',
            rtlDirCheck = new RegExp('^[^'+ltrChars+']*['+rtlChars+']');

        return rtlDirCheck.test(s);

    }

}
