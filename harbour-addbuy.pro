# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

# The name of your application
TARGET = harbour-addbuy

CONFIG += sailfishapp

SOURCES += src/harbour-addbuy.cpp

DISTFILES += qml/harbour-addbuy.qml \
    qml/cover/CoverPage.qml \
    qml/pages/LoadBudget.qml \
    qml/pages/NewTransaction.qml \
    qml/pages/Recent.qml \
    qml/pages/Settings.qml \
    qml/pages/BMClogowithwordmark-black.png \
    qml/pages/BMClogowithwordmark-white.png \
    rpm/harbour-addbuy.changes.in \
    rpm/harbour-addbuy.changes.run.in \
    rpm/harbour-addbuy.spec \
    rpm/harbour-addbuy.yaml \
    translations/*.ts \
    harbour-addbuy.desktop

SAILFISHAPP_ICONS = 86x86 108x108 128x128 172x172

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n

# German translation is enabled as an example. If you aren't
# planning to localize your app, remember to comment out the
# following TRANSLATIONS line. And also do not forget to
# modify the localized app name in the the .desktop file.
# TRANSLATIONS += translations/harbour-addbuy-de.ts

HEADERS += \
    src/networkpostaccess.h
