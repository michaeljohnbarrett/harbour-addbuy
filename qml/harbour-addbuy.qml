import QtQuick 2.6
import Sailfish.Silica 1.0
import Sailfish.WebView 1.0
import Sailfish.WebEngine 1.0
import Nemo.Configuration 1.0
import Nemo.Notifications 1.0
import "pages"

ApplicationWindow {

    id: appWindow
    initialPage: Component { LoadBudget { } }
    cover: Qt.resolvedUrl("cover/CoverPage.qml")
    allowedOrientations: defaultAllowedOrientations

    ConfigurationGroup {

        path: "/apps/harbour-addbuy"
        id: settings

        property string accessKey: ""
        property string defaultAccount: "notYetSetup"
        property int defaultAccountIndex
        property string defaultBudget: ""
        property int defaultBudgetIndex
        property var coverBalance1: ["Default Working", "defaultWorking", true, false]
        //property string coverBalance1Label
        //property int coverBalance1Index: 0
        //property bool coverBalance1Cleared
        //property bool coverBalance1Category
        property var coverBalance2: ["Default Cleared", "defaultCleared", true, true]
        //property string coverBalance2Label
        //property int coverBalance2Index: 1
        //property bool coverBalance2Cleared
        //property bool coverBalance2Category
        property int recentDaysBack: 0 // default is one week
        property bool recentsOldToNew
        property bool recentsShowBalances
        property bool recentsShowSelectedAcc

    }

    // currencySymbol[0]: what'll be to the left of figure, [1] will be to the right. [2] and [3] reserved for the new purchase page,
    // [4] for just the currency symbol.
    property var currencySymbol: ["string", "string", "string", "string", "string"]
    property var categoryName: ["string"]
    property var categoryID: ["string"]
    property var payeeName: ["string"]
    property var payeeNameToUpperCase: ["string"]
    property var payeeID: ["string"]
    property var accountName: ["string"]
    property var accountID: ["string"]
    property var budgetName: ["string"]
    property var budgetID: ["string"]
    property var recentsDate: ["- -"]
    property var recentsDateShort: ["- -"]
    property var recentsPayee: ["- -"]
    property var recentsCategory: ["- -"]
    property var recentsInflow: ["- -"]
    property var recentsOutflow: ["- -"]
    property var recentsUncleared: [false]
    property var accountClearedBal: ["string"]
    property var accountWorkingBal: ["string"]
    property var coverBalComboList: ["Default Account Working", "Default Account Cleared"]
    property bool symbolFirst
    property bool loginWithCookies: true
    property int chosenRecentsAccount
    property int chosenAccount
    property int decimalPlaces
    property int amountSendReady
    property int loadingProgress: 0
    property string categorySendReady
    property string payeeSendReady
    property string accountSendReady
    property string dateFormat
    property string decimalSeparator
    property string groupSeparator
    property string sinceDate
    property string assignedCategory
    property string workingBalance
    property string clearedBalance
    property string amountString
    property string inflowCatId

    ListModel {

        id: budgetCategoriesModel
        dynamicRoles: true

    }

    ListModel {

        id: budgetsModel

        ListElement {

            title: "Loading"; uuid: "string"

        }

    }

    ListModel {

        id: accountsModel

        ListElement {

            title: ""; uuid: "string"

        }

    }

    ListModel {

        id: coverBalComboModel

        ListElement {

            title: ""; uuid: ""; account: false; cleared: false

        }

    }

    onLoadingProgressChanged: {

        // Sum is 4 when all data types have loaded. User may run up number later in with changes to settings, not an issue so no need for ifs to cover that.
        if (loadingProgress === 4) pageStack.replace(Qt.resolvedUrl("pages/NewTransaction.qml"), null, PageStackAction.Immediate);

    }

    Notification {

        id: needNewKeyNotify
        appName: "AddBuy"
        isTransient: true
        previewSummary: qsTr("Authorization has expired. Please re-authorize.")
        expireTimeout: 2500

    }

    function loadBudgetSettings(url, callback) {

        var budgetSettingsFromServer = new XMLHttpRequest();

        budgetSettingsFromServer.onreadystatechange = (function(myxhr) {

            return function() {

                if (myxhr.readyState === 4) {

                    callback(myxhr);

                }

            }

        })(budgetSettingsFromServer);

        budgetSettingsFromServer.open('GET', url);
        budgetSettingsFromServer.setRequestHeader("Content-Type", "application/json");
        budgetSettingsFromServer.setRequestHeader("Accept", "application/json");
        budgetSettingsFromServer.setRequestHeader("Authorization", "Bearer " + settings.accessKey);
        budgetSettingsFromServer.send('');

    }

    function loadAccountBalances(url, callback) {

        var accountBalancesFromServer = new XMLHttpRequest();

        accountBalancesFromServer.onreadystatechange = (function(myxhr) {

            return function() {

                if (myxhr.readyState === 4) {

                    callback(myxhr);



                }

            }

        })(accountBalancesFromServer);

        accountBalancesFromServer.open('GET', url);
        accountBalancesFromServer.setRequestHeader("Content-Type", "application/json");
        accountBalancesFromServer.setRequestHeader("Accept", "application/json");
        accountBalancesFromServer.setRequestHeader("Authorization", "Bearer " + settings.accessKey);
        accountBalancesFromServer.send('');

    }

    function loadCategoryData(url, callback) {

        var categoryListFromServer = new XMLHttpRequest();

        categoryListFromServer.onreadystatechange = (function(myxhr) {

            return function() {

                if (myxhr.readyState === 4) {

                    callback(myxhr);

                }

            }

        })(categoryListFromServer);

        categoryListFromServer.open('GET', url);
        categoryListFromServer.setRequestHeader("Content-Type", "application/json");
        categoryListFromServer.setRequestHeader("Accept", "application/json");
        categoryListFromServer.setRequestHeader("Authorization", "Bearer " + settings.accessKey);
        categoryListFromServer.send('');

    }

    function formatFigure(amount) {

        var putBackMinusSign = false;

        if (amount === 0) {

            switch (decimalPlaces) {

            case 0:
                amountString = currencySymbol[0] + "0" + currencySymbol[1];
                break;
            case 2:
                amountString = currencySymbol[0] + "0.00" + currencySymbol[1];
                break;
            case 3:
                amountString = currencySymbol[0] + "0.000" + currencySymbol[1];

            }

        }

        else {

            if (amount < 0) {

                putBackMinusSign = true;
                amount = amount * -1;

            }

            switch (decimalPlaces) {

                case 0:

                    amountString = (amount / 10).toString();

                    if (amountString.length > 3) {

                        amountString = amountString.slice(0, (amountString.length - 3)) + groupSeparator + amountString.slice((amountString.length - 3), amountString.length);

                        if (amountString.length > 7) {

                            amountString = amountString.slice(0, (amountString.length - 7)) + groupSeparator + amountString.slice((amountString.length - 7), amountString.length);

                            if (amountString.length > 11) amountString = amountString.slice(0, (amountString.length - 11)) + groupSeparator + amountString.slice((amountString.length - 11), amountString.length);

                        }

                    }

                break;

                case 2:

                    amountString = (amount / 10).toString();

                    if (amountString.length < 3) {

                        if (amountString.length < 2) amountString = "0" + amountString;
                        amountString = "0" + amountString;

                    }

                    amountString = amountString.slice(0, (amountString.length - decimalPlaces)) + decimalSeparator + amountString.slice((amountString.length - decimalPlaces), amountString.length);

                    if (amountString.length > 6) {

                        amountString = amountString.slice(0, (amountString.length - 6)) + groupSeparator + amountString.slice((amountString.length - 6), amountString.length);

                        if (amountString.length > 10) amountString = amountString.slice(0, (amountString.length - 10)) + groupSeparator + amountString.slice((amountString.length - 10), amountString.length);

                    }

                break;

                case 3:

                    amountString = (amount).toString();

                    if (amountString.length < 4) {

                        if (amountString.length < 3) {

                            if (amountString.length < 2) amountString = "0" + amountString;
                            amountString = "0" + amountString

                        }

                        amountString = "0" + amountString;

                    }

                    amountString = amountString.slice(0, (amountString.length - decimalPlaces)) + decimalSeparator + amountString.slice((amountString.length - decimalPlaces), amountString.length);

                    if (amountString.length > 7) {

                        amountString = amountString.slice(0, (amountString.length - 7)) + groupSeparator + amountString.slice((amountString.length - 7), amountString.length);

                        if (amountString.length > 11) amountString = amountString.slice(0, (amountString.length - 11)) + groupSeparator + amountString.slice((amountString.length - 11), amountString.length);

                    }

            }

            if (putBackMinusSign) amountString = "-" + currencySymbol[0] + amountString + currencySymbol[1];
            else amountString = currencySymbol[0] + amountString + currencySymbol[1];

        }

        return(amountString);

    }

    function needNewKey() {

        needNewKeyNotify.previewSummary = "Access Expired - Reauthorizing...";
        needNewKeyNotify.publish();
        loadingProgress = 0;
        settings.accessKey = "";
        settings.sync();
        pageStack.clear();
        pageStack.replace(Qt.resolvedUrl("pages/LoadBudget.qml"));

    }

}
