import QtQuick 2.6
import Sailfish.Silica 1.0
import Nemo.Configuration 1.0

Page {

    id: page
    allowedOrientations: Orientation.All

    SilicaListView {

        width: parent.width
        contentHeight: column.height
        id: mainListView
        spacing: Theme.paddingSmall

        Column {

            id: column
            width: parent.width

            PageHeader {

                id: mainPageHeader
                title: qsTr("Budget")
                visible: isPortrait ? true : false

            }

            Row {

                width: parent.width
                spacing: 0
                id: categoriesHeaderRow

                ListView {

                    id: budgetCategoriesListView
                    model: budgetCategoriesModel
                    height: isPortrait ? page.height - mainPageHeader.height - gapRow.height : page.height - gapRow.height
                    width: parent.width

                    VerticalScrollDecorator { flickable: budgetCategoriesListView }

                    delegate: Column {

                        width: parent.width
                        spacing: 0

                        Row {

                            width: parent.width
                            spacing: 0
                            visible: groupNameVis ? true : false

                            SectionHeader {

                                width: parent.width
                                topPadding: model.index === 0 ? 0 : Theme.paddingSmall
                                leftPadding: Theme.horizontalPageMargin
                                rightPadding: Theme.horizontalPageMargin
                                bottomPadding: Theme.paddingSmall
                                text: groupName
                                font.pixelSize: isPortrait ? Theme.fontSizeSmall : Theme.fontSizeMedium

                            }

                        }

                        Row {

                            id: headersRow
                            width: parent.width - (Theme.horizontalPageMargin * 2)
                            spacing: 0
                            x: Theme.horizontalPageMargin
                            visible: groupNameVis ? true : false

                            Label {

                                text: qsTr("Category")
                                font.pixelSize: Theme.fontSizeExtraSmall
                                color: Theme.secondaryColor
                                topPadding: Theme.paddingSmall
                                bottomPadding:  Theme.paddingSmall
                                truncationMode: TruncationMode.Fade
                                width: isPortrait ? parent.width * 0.6 : parent.width * 0.4

                            }

                            Label {

                                text: qsTr("Budgeted")
                                visible: isPortrait ? false : true
                                font.pixelSize: Theme.fontSizeExtraSmall
                                color: Theme.secondaryColor
                                topPadding: Theme.paddingSmall
                                bottomPadding:  Theme.paddingSmall
                                truncationMode: TruncationMode.Fade
                                horizontalAlignment: "AlignRight"
                                width: parent.width * 0.2

                            }

                            Label {

                                text: qsTr("Activity")
                                visible: isPortrait ? false : true
                                font.pixelSize: Theme.fontSizeExtraSmall
                                color: Theme.secondaryColor
                                topPadding: Theme.paddingSmall
                                bottomPadding:  Theme.paddingSmall
                                truncationMode: TruncationMode.Fade
                                horizontalAlignment: "AlignRight"
                                width: parent.width * 0.2

                            }

                            Label {

                                text: qsTr("Balance")
                                font.pixelSize: Theme.fontSizeExtraSmall
                                color: Theme.secondaryColor
                                topPadding: Theme.paddingSmall
                                bottomPadding:  Theme.paddingSmall
                                truncationMode: TruncationMode.Fade
                                horizontalAlignment: "AlignRight"
                                width: isPortrait ? parent.width * 0.4 : parent.width * 0.2

                            }

                        }

                        Row {

                            width: parent.width - (Theme.horizontalPageMargin * 2)
                            spacing: 0
                            visible: catNamesVis ? true : false
                            x: Theme.horizontalPageMargin

                            Label {

                                text: categories.name
                                font.pixelSize: Theme.fontSizeSmall
                                topPadding: Theme.paddingSmall
                                bottomPadding: Theme.paddingSmall
                                truncationMode: TruncationMode.Fade
                                width: isPortrait ? parent.width * 0.6 : parent.width * 0.4

                            }

                            Label {

                                text: categories.budgeted
                                visible: isPortrait ? false : true
                                font.pixelSize: Theme.fontSizeSmall
                                topPadding: Theme.paddingSmall
                                bottomPadding: Theme.paddingSmall
                                truncationMode: TruncationMode.Fade
                                horizontalAlignment: "AlignRight"
                                width: parent.width * 0.2

                            }

                            Label {

                                text: categories.activity
                                visible: isPortrait ? false : true
                                font.pixelSize: Theme.fontSizeSmall
                                topPadding: Theme.paddingSmall
                                bottomPadding: Theme.paddingSmall
                                truncationMode: TruncationMode.Fade
                                horizontalAlignment: "AlignRight"
                                width: parent.width * 0.2

                            }

                            Label {

                                text: categories.balance
                                font.pixelSize: Theme.fontSizeSmall
                                topPadding: Theme.paddingSmall
                                bottomPadding: Theme.paddingSmall
                                truncationMode: TruncationMode.Fade
                                horizontalAlignment: "AlignRight"
                                width: isPortrait ? parent.width * 0.4 : parent.width * 0.2

                            }

                        }

                    }

                }

            }

            Row {

                id: gapRow
                width: parent.width
                height: Theme.paddingMedium

            }

        }

    }

}
