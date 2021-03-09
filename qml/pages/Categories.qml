import QtQuick 2.2
import Sailfish.Silica 1.0
import Nemo.Configuration 1.0

Page {

    id: page
    allowedOrientations: Orientation.All

    SilicaListView {

        width: parent.width
        contentHeight: column.height
        id: mainListView
        spacing: isPortrait ? Theme.paddingSmall : Theme.paddingSmall

        Column {

            id: column
            width: parent.width

            PageHeader {

                id: mainPageHeader
                title: "Budget"
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
                                leftPadding: isPortrait ? Theme.paddingMedium * 1.5 : Theme.paddingMedium * 2.5
                                rightPadding: isPortrait ? Theme.paddingMedium * 1.5 : Theme.paddingMedium * 2.5
                                bottomPadding: Theme.paddingSmall
                                text: groupName
                                font.pixelSize: isPortrait ? Theme.fontSizeSmall : Theme.fontSizeMedium

                            }

                        }

                        Row {

                            id: headersRow
                            width: parent.width
                            spacing: 0
                            x: isPortrait ? Theme.paddingMedium * 1.5 : Theme.paddingMedium * 2.5
                            visible: groupNameVis ? true : false

                            Label {

                                text: "Category"
                                font.pixelSize: Theme.fontSizeExtraSmall
                                color: Theme.secondaryColor
                                topPadding: Theme.paddingSmall
                                bottomPadding:  Theme.paddingSmall
                                truncationMode: TruncationMode.Fade
                                width: isPortrait ? parent.width * 0.6 - (Theme.paddingMedium * 1.5) : parent.width * 0.4 - (Theme.paddingMedium * 2.5)

                            }

                            Label {

                                text: "Budgeted"
                                visible: isPortrait ? false : true
                                font.pixelSize: Theme.fontSizeExtraSmall
                                color: Theme.secondaryColor
                                topPadding: Theme.paddingSmall
                                bottomPadding:  Theme.paddingSmall
                                truncationMode: TruncationMode.Fade
                                horizontalAlignment: "AlignRight"
                                width: (parent.width * 0.2)

                            }

                            Label {

                                text: "Activity"
                                visible: isPortrait ? false : true
                                font.pixelSize: Theme.fontSizeExtraSmall
                                color: Theme.secondaryColor
                                topPadding: Theme.paddingSmall
                                bottomPadding:  Theme.paddingSmall
                                truncationMode: TruncationMode.Fade
                                horizontalAlignment: "AlignRight"
                                width: (parent.width * 0.2)

                            }

                            Label {

                                text: "Balance"
                                font.pixelSize: Theme.fontSizeExtraSmall
                                color: Theme.secondaryColor
                                topPadding: Theme.paddingSmall
                                bottomPadding:  Theme.paddingSmall
                                truncationMode: TruncationMode.Fade
                                horizontalAlignment: "AlignRight"
                                width: isPortrait ? (parent.width * 0.4) - (Theme.paddingMedium * 1.5) : (parent.width * 0.2) - (Theme.paddingMedium * 2.5)

                            }

                        }

                        Row {

                            width: parent.width
                            spacing: 0
                            visible: catNamesVis ? true : false
                            x: isPortrait ? Theme.paddingMedium * 1.5 : Theme.paddingMedium * 2.5

                            Label {

                                text: categories.name
                                font.pixelSize: Theme.fontSizeSmall
                                topPadding: Theme.paddingSmall
                                bottomPadding: Theme.paddingSmall
                                truncationMode: TruncationMode.Fade
                                width: isPortrait ? (parent.width * 0.6) - (Theme.paddingMedium * 1.5) : (parent.width * 0.4) - (Theme.paddingMedium * 2.5)

                            }

                            Label {

                                text: categories.budgeted
                                visible: isPortrait ? false : true
                                font.pixelSize: Theme.fontSizeSmall
                                topPadding: Theme.paddingSmall
                                bottomPadding: Theme.paddingSmall
                                truncationMode: TruncationMode.Fade
                                horizontalAlignment: "AlignRight"
                                width: (parent.width * 0.2)

                            }

                            Label {

                                text: categories.activity
                                visible: isPortrait ? false : true
                                font.pixelSize: Theme.fontSizeSmall
                                topPadding: Theme.paddingSmall
                                bottomPadding: Theme.paddingSmall
                                truncationMode: TruncationMode.Fade
                                horizontalAlignment: "AlignRight"
                                width: (parent.width * 0.2)

                            }

                            Label {

                                text: categories.balance
                                font.pixelSize: Theme.fontSizeSmall
                                topPadding: Theme.paddingSmall
                                bottomPadding: Theme.paddingSmall
                                truncationMode: TruncationMode.Fade
                                horizontalAlignment: "AlignRight"
                                width: isPortrait ? (parent.width * 0.4) - (Theme.paddingMedium * 1.5) : (parent.width * 0.2) - (Theme.paddingMedium * 2.5)

                            }

                        }

                    }

                }

            }

            Row {

                id: gapRow
                width: parent.width
                height: Theme.paddingSmall

            }

        }

    }

}
