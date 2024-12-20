TARGET  = toolBLEx

VERSION = 0.14
DEFINES+= APP_NAME=\\\"$$TARGET\\\"
DEFINES+= APP_VERSION=\\\"$$VERSION\\\"

CONFIG += c++17
QT     += core bluetooth sql
QT     += widgets svg
QT     += qml quick quickcontrols2 charts

# Validate Qt version
!versionAtLeast(QT_VERSION, 6.5) : error("You need at least Qt version 6.5 for $${TARGET}")

# Project modules ##############################################################

# SingleApplication
DEFINES += QAPPLICATION_CLASS=QApplication
include(thirdparty/SingleApplication/SingleApplication.pri)

# AppUtils
CONFIG += UTILS_DOCK_ENABLED
include(thirdparty/AppUtils/AppUtils.pri)

# Project files ################################################################

SOURCES  += src/main.cpp \
            src/SettingsManager.cpp \
            src/MenubarManager.cpp \
            src/DatabaseManager.cpp \
            src/DeviceManager.cpp \
            src/DeviceManager_advertisement.cpp \
            src/DeviceManager_rssigraph.cpp \
            src/DeviceFilter.cpp \
            src/VendorsDatabase.cpp \
            src/ubertooth.cpp \
            src/adapter.cpp \
            src/device.cpp \
            src/device_toolblex.cpp \
            src/device_toolblex_adv.cpp \
            src/BleServiceInfo.cpp \
            src/BleCharacteristicInfo.cpp

HEADERS  += src/SettingsManager.h \
            src/MenubarManager.h \
            src/DatabaseManager.h \
            src/DeviceManager.h \
            src/DeviceHeader.h \
            src/DeviceFilter.h \
            src/VendorsDatabase.h \
            src/ubertooth.h \
            src/adapter.h \
            src/device.h \
            src/device_utils.h \
            src/device_toolblex.h \
            src/device_toolblex_adv.h \
            src/BleServiceInfo.h \
            src/BleCharacteristicInfo.h

INCLUDEPATH += src/ src/thirdparty/

RESOURCES   += assets/assets.qrc \
               assets/vendors.qrc \
               i18n/i18n.qrc \
               qml/qml.qrc \
               thirdparty/IconLibrary/IconLibrary.qrc \
               thirdparty/ComponentLibrary/ComponentLibrary.qrc

TRANSLATIONS = i18n/toolBLEx_en.ts

lupdate_only {
    SOURCES += qml/*.qml qml/*.js \
               qml/popups/*.qml \
               qml/components/*.qml qml/components_generic/*.qml qml/components_js/*.js
}

OTHER_FILES += README.md \
               deploy_linux.sh \
               deploy_macos.sh \
               deploy_windows.sh \
               .github/workflows/builds_desktop_qmake.yml \
               .gitignore

# Build settings ###############################################################

CONFIG(release, debug|release) : DEFINES += NDEBUG QT_NO_DEBUG QT_NO_DEBUG_OUTPUT

# Build artifacts ##############################################################

OBJECTS_DIR = build/$${QT_ARCH}/
MOC_DIR     = build/$${QT_ARCH}/
RCC_DIR     = build/$${QT_ARCH}/
UI_DIR      = build/$${QT_ARCH}/

DESTDIR     = bin/

################################################################################
# Application deployment and installation steps

linux:!android {
    TARGET = $$lower($${TARGET})

    # Automatic application packaging # Needs linuxdeployqt installed
    #system(linuxdeployqt $${OUT_PWD}/$${DESTDIR}/ -qmldir=qml/)

    # Application packaging # Needs linuxdeployqt installed
    #deploy.commands = $${OUT_PWD}/$${DESTDIR}/ -qmldir=qml/
    #install.depends = deploy
    #QMAKE_EXTRA_TARGETS += install deploy

    # Installation steps
    isEmpty(PREFIX) { PREFIX = /usr/local }
    target_app.files           += $${OUT_PWD}/$${DESTDIR}/$$lower($${TARGET})
    target_app.path             = $${PREFIX}/bin/
    target_appentry.files      += $${OUT_PWD}/assets/linux/$$lower($${TARGET}).desktop
    target_appentry.path        = $${PREFIX}/share/applications
    target_appdata.files       += $${OUT_PWD}/assets/linux/$$lower($${TARGET}).appdata.xml
    target_appdata.path         = $${PREFIX}/share/appdata
    target_icon_appimage.files += $${OUT_PWD}/assets/linux/$$lower($${TARGET}).svg
    target_icon_appimage.path   = $${PREFIX}/share/pixmaps/
    target_icon_flatpak.files  += $${OUT_PWD}/assets/linux/$$lower($${TARGET}).svg
    target_icon_flatpak.path    = $${PREFIX}/share/icons/hicolor/scalable/apps/
    INSTALLS += target_app target_appentry target_appdata target_icon_appimage target_icon_flatpak

    # Clean appdir/ and bin/ directories
    #QMAKE_CLEAN += $${OUT_PWD}/$${DESTDIR}/$$lower($${TARGET})
    #QMAKE_CLEAN += $${OUT_PWD}/appdir/
}

macx {
    # Bundle name
    QMAKE_TARGET_BUNDLE_PREFIX = io.emeric
    QMAKE_BUNDLE = toolBLEx

    # OS icons
    ICON = $${PWD}/assets/macos/$${TARGET}.icns
    #QMAKE_ASSET_CATALOGS_APP_ICON = "AppIcon"
    #QMAKE_ASSET_CATALOGS = $${PWD}/assets/macos/Images.xcassets

    # OS infos
    QMAKE_INFO_PLIST = $${PWD}/assets/macos/Info.plist

    # OS entitlement (sandbox and stuff)
    ENTITLEMENTS.name = CODE_SIGN_ENTITLEMENTS
    ENTITLEMENTS.value = $${PWD}/assets/macos/$${TARGET}.entitlements
    QMAKE_MAC_XCODE_SETTINGS += ENTITLEMENTS

    # Target architecture(s)
    QMAKE_APPLE_DEVICE_ARCHS = x86_64 arm64

    # Target OS
    QMAKE_MACOSX_DEPLOYMENT_TARGET = 11.0

    # Automatic bundle packaging

    # Deploy step (app bundle packaging)
    deploy.commands = macdeployqt $${OUT_PWD}/$${DESTDIR}/$${TARGET}.app -qmldir=qml/ -appstore-compliant
    install.depends = deploy
    QMAKE_EXTRA_TARGETS += install deploy

    # Installation step (note: app bundle packaging)
    isEmpty(PREFIX) { PREFIX = /usr/local }
    target.files += $${OUT_PWD}/${DESTDIR}/${TARGET}.app
    target.path = $$(HOME)/Applications
    INSTALLS += target

    # Clean step
    QMAKE_DISTCLEAN += -r $${OUT_PWD}/${DESTDIR}/${TARGET}.app
}

win32 {
    # OS icon
    RC_ICONS = $${PWD}/assets/windows/$${TARGET}.ico

    # Deploy step
    deploy.commands = $$quote(windeployqt $${OUT_PWD}/$${DESTDIR}/ --qmldir qml/)
    install.depends = deploy
    QMAKE_EXTRA_TARGETS += install deploy

    # Installation step
    # TODO

    # Clean step
    # TODO
}
