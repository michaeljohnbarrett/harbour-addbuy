import QtQuick 2.0
import Sailfish.Silica 1.0

CoverBackground {

    id: coverPage
    allowResize: true
    property bool authOrNetworkError

    ListModel {

        id: coverBalancesModel

        ListElement {

            balDescription: ""
            balFigure: ""

        }

        ListElement {

            balDescription: ""
            balFigure: ""

        }

    }

    Column {

        id: titleColumn

        anchors {

            left: coverPage.left
            right: coverPage.right
            top: coverPage.top
            bottom: coverActionArea.top

        }

        Behavior on opacity {

            FadeAnimator {

                duration: 150

            }

        }

        Row {

            width: parent.width
            height: coverPage.height * 0.4
            spacing: 0

            Label {

                id: description
                text: "AddBuy"
                wrapMode: Text.Wrap
                font.pixelSize: coverPage.size === Cover.Large ? Theme.fontSizeLarge : Theme.fontSizeMedium
                width: parent.width
                height: parent.height
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignBottom

            }

        }

    }

    SilicaListView {

        id: balancesListView
        visible: false
        model: coverBalancesModel

        anchors {

            left: coverPage.left
            right: coverPage.right
            top: coverPage.top
            bottom: coverActionArea.top
            topMargin: coverPage.size === Cover.Large ? Theme.paddingLarge : Theme.paddingMedium
            bottomMargin: Theme.paddingMedium
            leftMargin: coverPage.size === Cover.Large ? Theme.paddingLarge : Theme.paddingMedium
            rightMargin: coverPage.size === Cover.Large ? Theme.paddingLarge : Theme.paddingMedium

        }

        Behavior on opacity {

            FadeAnimator {

                duration: 150

            }

        }

        delegate: ListItem {

            id: delegateItem
            width: parent.width
            height: coverPage.size === Cover.Large ? coverPage.height * 0.4 : coverPage.height * 0.38

            Column {

                anchors.fill: parent

                Label {

                    id: balDescriptionLabel
                    text: balDescription
                    font.pixelSize: coverPage.size === Cover.Large ? Theme.fontSizeSmall : Theme.fontSizeExtraSmall
                    width: delegateItem.width
                    height: (delegateItem.height - theSpaceBetween.height) * 0.45
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignBottom
                    maximumLineCount: coverPage.size === Cover.Large ? 2 : 1
                    truncationMode: coverPage.size === Cover.Large ? TruncationMode.None : TruncationMode.Fade
                    wrapMode: coverPage.size === Cover.Large ? Text.Wrap : Text.NoWrap
                    color: model.index === 0 ? (authOrNetworkError ? Theme.errorColor : Theme.secondaryColor) : (authOrNetworkError ? Theme.primaryColor : Theme.secondaryColor)
                    fontSizeMode: Text.Fit
                    minimumPixelSize: coverPage.size === Cover.Large ? Theme.fontSizeSmall : Theme.fontSizeTiny

                }

                Label {

                    id: balFigureLabel
                    text: balFigure
                    font.pixelSize: coverPage.size === Cover.Large ? Theme.fontSizeHuge : Theme.fontSizeLarge
                    width: delegateItem.width
                    height: (delegateItem.height - theSpaceBetween.height) * 0.55
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignTop
                    truncationMode: TruncationMode.Fade
                    maximumLineCount: 1
                    fontSizeMode: Text.Fit
                    minimumPixelSize: coverPage.size === Cover.Large ? Theme.fontSizeLarge : Theme.fontSizeSmall

                }

                Item {

                    id: theSpaceBetween
                    width: parent.width
                    height: Theme.paddingMedium
                    visible: coverPage.size === Cover.Large

                }

            }

        }

    }

    CoverActionList {

        id: coverAction

        CoverAction {

            iconSource: "image://theme/icon-cover-subview"
            id: refreshCoverAction

            onTriggered: {

                if (titleColumn.opacity == 1.0) {

                    titleColumn.opacity = 0.0;
                    titleColumn.visible = false;
                    balancesListView.visible = true;
                    balancesListView.opacity = 1.0;

                    var balDescription1, balDescription2, balFigure1, balFigure2;

                    if (settings.coverBalance1[2] === true || settings.coverBalance2[2] === true) { // at least one is an account

                        loadAccountBalances('https://api.youneedabudget.com/v1/budgets/' + settings.defaultBudget + '/accounts', function (o) {

                            var accountBalances = JSON.parse(o.responseText);

                            if (o.status === 200) {

                                authOrNetworkError = false;
                                var coverBalAccountUuid;

                                if (settings.coverBalance1[2]) {

                                    if (settings.coverBalance1[1] === "defaultWorking" || settings.coverBalance1[1] === "defaultCleared") coverBalAccountUuid = settings.defaultAccount;
                                    else coverBalAccountUuid = settings.coverBalance1[1];

                                    for (var i = 0; i < accountBalances.data.accounts.length; i++) {

                                        if (coverBalAccountUuid === accountBalances.data.accounts[i].id) {

                                            if (settings.coverBalance1[3]) { // cleared balance

                                                balDescription1 = "Cleared " + accountBalances.data.accounts[i].name;
                                                balFigure1 = formatFigure(accountBalances.data.accounts[i].cleared_balance);
                                                coverBalancesModel.set(0, {balDescription: balDescription1, balFigure: balFigure1});

                                            }

                                            else {

                                                balDescription1 = "Working " + accountBalances.data.accounts[i].name;
                                                balFigure1 = formatFigure(accountBalances.data.accounts[i].balance);
                                                coverBalancesModel.set(0, {balDescription: balDescription1, balFigure: balFigure1});

                                            }

                                        }

                                    }

                                }

                                if (settings.coverBalance2[2]) { // type is account

                                    if (settings.coverBalance2[1] === "defaultWorking" || settings.coverBalance2[1] === "defaultCleared") coverBalAccountUuid = settings.defaultAccount;
                                    else coverBalAccountUuid = settings.coverBalance2[1];

                                    for (var j = 0; j < accountBalances.data.accounts.length; j++) {

                                        if (coverBalAccountUuid === accountBalances.data.accounts[j].id) {

                                            if (settings.coverBalance2[3]) { // cleared balance

                                                balDescription2 = "Cleared " + accountBalances.data.accounts[j].name;
                                                balFigure2 = formatFigure(accountBalances.data.accounts[j].cleared_balance);
                                                coverBalancesModel.set(1, {balDescription: balDescription2, balFigure: balFigure2});

                                            }

                                            else {

                                                balDescription2 = "Working " + accountBalances.data.accounts[j].name;
                                                balFigure2 = formatFigure(accountBalances.data.accounts[j].balance);
                                                coverBalancesModel.set(1, {balDescription: balDescription2, balFigure: balFigure2});

                                            }

                                        }

                                    }

                                }

                            }

                            else if (o.status === 401 || o.status === 403) {

                                authOrNetworkError = true;
                                coverBalancesModel.set(0, {balDescription: "Authorization Error", balFigure: ""});
                                coverBalancesModel.set(1, {balDescription: "Please reauthorize.", balFigure: ""});

                            }

                            else if (o.status === 503) {

                                authOrNetworkError = true;
                                coverBalancesModel.set(0, {balDescription: "API Unavailable", balFigure: ""});
                                coverBalancesModel.set(1, {balDescription: "Please try again later.", balFigure: ""});

                            }

                            else {

                                authOrNetworkError = true;
                                coverBalancesModel.set(0, {balDescription: "Server Error", balFigure: ""});
                                coverBalancesModel.set(1, {balDescription: "Please setup AddBuy.", balFigure: ""});

                            }

                        });

                    }

                    if (settings.coverBalance1[2] === false || settings.coverBalance2[2] === false) { // at least one is a category balance

                        // possible to just grab one category balance if there's only one selected but can use this to refresh overall category list so will gather all data.

                        loadCategoryData('https://api.youneedabudget.com/v1/budgets/' + settings.defaultBudget + '/categories', function (o) {

                            var categoryList = JSON.parse(o.responseText);

                            if (o.status === 200) {

                                authOrNetworkError = false;
                                var k = 1; // for overall category count - first entry reserved for 'Default'
                                budgetCategoriesModel.clear();

                                // gather ID for Inflow category
                                inflowCatId = categoryList.data.category_groups[0].categories[1].id;

                                for (var i = 1; i < categoryList.data.category_groups.length; i++) { // '1' instead of '0' because we skip first category group (internal)

                                    if (categoryList.data.category_groups[i].hidden === false && categoryList.data.category_groups[i].name !== "Hidden Categories") {

                                        budgetCategoriesModel.append({ "groupName": categoryList.data.category_groups[i].name, "groupNameVis": true, "catNamesVis": false, "categories": {"name": "", "uuid": "", "budgeted": "", "activity": "", "balance": ""} });

                                        for (var j = 0; j < categoryList.data.category_groups[i].categories.length; j++) {

                                            if (categoryList.data.category_groups[i].categories[j].hidden === false) {

                                                var categoryAmounts = ["string"];

                                                if (settings.coverBalance1[2] === false) {

                                                    if (settings.coverBalance1[1] === categoryList.data.category_groups[i].categories[j].id) {

                                                        balDescription1 = categoryList.data.category_groups[i].categories[j].name;
                                                        balFigure1 = formatFigure(categoryList.data.category_groups[i].categories[j].activity);
                                                        coverBalancesModel.set(0, {balDescription: balDescription1, balFigure: balFigure1});

                                                    }

                                                }

                                                if (settings.coverBalance2[2] === false) {

                                                    if (settings.coverBalance2[1] === categoryList.data.category_groups[i].categories[j].id) {

                                                        balDescription2 = categoryList.data.category_groups[i].categories[j].name;
                                                        balFigure2 = formatFigure(categoryList.data.category_groups[i].categories[j].activity);
                                                        coverBalancesModel.set(1, {balDescription: balDescription2, balFigure: balFigure2});

                                                    }

                                                }

                                                categoryAmounts[0] = formatFigure(categoryList.data.category_groups[i].categories[j].budgeted);
                                                categoryAmounts[1] = formatFigure(categoryList.data.category_groups[i].categories[j].activity);
                                                categoryAmounts[2] = formatFigure(categoryList.data.category_groups[i].categories[j].balance);

                                                categoryName[k] = categoryList.data.category_groups[i].categories[j].name;
                                                categoryID[k] = categoryList.data.category_groups[i].categories[j].id;
                                                coverBalComboList[k+1] = categoryList.data.category_groups[i].categories[j].name + " Available";

                                                budgetCategoriesModel.append({ "groupName": "", "groupNameVis": false, "catNamesVis": true, "categories": { "name": categoryList.data.category_groups[i].categories[j].name, "uuid": categoryList.data.category_groups[i].categories[j].id, "budgeted": categoryAmounts[0], "activity": categoryAmounts[1], "balance": categoryAmounts[2] }});
                                                k++;

                                            }

                                        }

                                    }

                                }

                            }

                            else if (o.status === 401 || o.status === 403) {

                                authOrNetworkError = true;
                                coverBalancesModel.set(0, {balDescription: "Authorization Error", balFigure: ""});
                                coverBalancesModel.set(1, {balDescription: "Please reauthorize in app.", balFigure: ""});

                            }

                            else if (o.status === 503) {

                                authOrNetworkError = true;
                                coverBalancesModel.set(0, {balDescription: "API Unavailable", balFigure: ""});
                                coverBalancesModel.set(1, {balDescription: "Please try again later.", balFigure: ""});

                            }

                            else {

                                authOrNetworkError = true;
                                coverBalancesModel.set(0, {balDescription: "Server Error", balFigure: ""});
                                coverBalancesModel.set(1, {balDescription: "Please setup AddBuy.", balFigure: ""});

                            }

                        });

                    }

                    refreshCoverAction.iconSource = "image://theme/icon-cover-cancel";

                }

                else {

                    balancesListView.opacity = 0.0;
                    balancesListView.visible = false;
                    titleColumn.visible = true;
                    titleColumn.opacity = 1.0;
                    refreshCoverAction.iconSource = "image://theme/icon-cover-subview";

                }

            }

        }

    }

}
