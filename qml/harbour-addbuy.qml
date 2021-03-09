import QtQuick 2.2
import Sailfish.Silica 1.0
import Nemo.Configuration 1.0
import Nemo.Notifications 1.0
import "pages"

ApplicationWindow {

    id: appWindow

    initialPage: Component {

        LoadBudget { }

    }

    cover: Qt.resolvedUrl("cover/CoverPage.qml")
    allowedOrientations: defaultAllowedOrientations

    ConfigurationGroup {

        path: "/apps/harbour-addbuy"
        id: settings

        // Pending addition of Sailfish Secrets, after which will be able to securely store access key and/or add OAuth (even with two-hour limit).
        property string accessKey: "AccessKeyHere"
        property string defaultAccount: "notYetSetup"
        property int defaultAccountIndex
        property string defaultBudget: "notYetSetup"
        property int defaultBudgetIndex
        property var recentDaysBack: 1 // default to 2 weeks
        property bool recentsOldToNew
        property bool recentsShowBalances

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
    property var recentsPayee: ["- -"]
    property var recentsCategory: ["- -"]
    property var recentsInflow: ["- -"]
    property var recentsOutflow: ["- -"]
    property var recentsUncleared: [false]
    property var accountClearedBal: ["string"]
    property var accountWorkingBal: ["string"]
    property bool symbolFirst
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

    onLoadingProgressChanged: {

        // Sum is 5 when all data types have loaded. User may run up number later in with changes to settings, not an issue so no need for ifs to cover that.
        if (loadingProgress === 5) pageStack.replace(Qt.resolvedUrl("pages/NewTransaction.qml"), null, PageStackAction.Immediate);

    }

    // Here to be accessible by both LoadBudget and Settings.

    function loadBudgetSettings(url, callback) {

        var budgetSettingsFromServer = new XMLHttpRequest();

        budgetSettingsFromServer.onreadystatechange = (function(myxhr) {

            return function() {

                if (myxhr.readyState === 4) {

                    callback(myxhr);

                    if (budgetSettingsFromServer.status === 200) {

                        loadingProgress = loadingProgress + 1;

                    }

                    else {

                        console.log("Error from server: " + budgetSettingsFromServer.status);

                    }

                }

                else {

                    // Current network connection attempt status for budget settings.

                }

            }

        })(budgetSettingsFromServer);

        budgetSettingsFromServer.open('GET', url);
        budgetSettingsFromServer.setRequestHeader("Content-Type", "application/json");
        budgetSettingsFromServer.setRequestHeader("Accept", "application/json");
        budgetSettingsFromServer.setRequestHeader("Authorization", "Bearer " + settings.accessKey);
        budgetSettingsFromServer.send('');

    }

}
