#!/usr/bin/env bash

export APP_NAME="toolBLEx"
export APP_VERSION=0.14
export GIT_VERSION=$(git rev-parse --short HEAD)

export APP_NAME_LOWERCASE=${APP_NAME,,}   # lowercase
#export APP_NAME_LOWERCASE=$APP_NAME      # not actually lowercase

echo "> $APP_NAME packager (Linux x86_64) [v$APP_VERSION]"

## CHECKS ######################################################################

if [ "$(id -u)" == "0" ]; then
  echo "This script MUST NOT be run as root" 1>&2
  exit 1
fi

if [ ${PWD##*/} != $APP_NAME ]; then
  echo "This script MUST be run from the $APP_NAME/ directory"
  exit 1
fi

## SETTINGS ####################################################################

use_contribs=false
make_install=false
create_package=false
upload_package=false

while [[ $# -gt 0 ]]
do
case $1 in
  -c|--contribs)
  use_contribs=true
  ;;
  -i|--install)
  make_install=true
  ;;
  -p|--package)
  create_package=true
  ;;
  -u|--upload)
  upload_package=true
  ;;
  *)
  echo "> Unknown argument '$1'"
  ;;
esac
shift # skip argument or value
done

## linuxdeploy INSTALL #########################################################

#unset LD_LIBRARY_PATH; #unset QT_PLUGIN_PATH; #unset QTDIR;

if [[ $use_contribs = true ]] ; then
  export LD_LIBRARY_PATH=$(pwd)/contribs/src/env/linux_x86_64/usr/lib/:/usr/lib
else
  export LD_LIBRARY_PATH=/usr/lib/
fi

echo '---- Prepare linuxdeploy + plugins'

# linuxdeploy and plugins
if [ ! -x contribs/deploy/linuxdeploy-x86_64.AppImage ]; then
  wget -c -nv "https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage" -P contribs/deploy/
  wget -c -nv "https://github.com/linuxdeploy/linuxdeploy-plugin-appimage/releases/download/continuous/linuxdeploy-plugin-appimage-x86_64.AppImage" -P contribs/deploy/
  wget -c -nv "https://github.com/linuxdeploy/linuxdeploy-plugin-qt/releases/download/continuous/linuxdeploy-plugin-qt-x86_64.AppImage" -P contribs/deploy/
fi
chmod a+x contribs/deploy/linuxdeploy-x86_64.AppImage
chmod a+x contribs/deploy/linuxdeploy-plugin-appimage-x86_64.AppImage
chmod a+x contribs/deploy/linuxdeploy-plugin-qt-x86_64.AppImage

# linuxdeploy qt hacks
#export QMAKE="qmake6" # force Qt6, if you have Qt5 installed
#export NO_STRIP=true  # workaround, strip not working on modern binutils

# linuxdeploy qt settings
export EXTRA_PLATFORM_PLUGINS="libqwayland-egl.so;libqwayland-generic.so;"
export EXTRA_QT_PLUGINS="wayland-shell-integration;waylandclient;wayland-graphics-integration-client;"
export EXTRA_QT_MODULES="svg;"
export QML_SOURCES_PATHS="$(pwd)/qml/"
export QML_MODULES_PATHS=""

## APP INSTALL #################################################################

if [[ $make_install = true ]] ; then
  echo '---- Running make install'
  make INSTALL_ROOT=bin/ install

  #echo '---- Installation directory content recap (after make install):'
  #find bin/
fi

## PACKAGES ####################################################################

if [[ $create_package = true ]] ; then
  if [[ -v QT_ROOT_DIR ]]; then
    # cleanup undeployable Qt plugins (present, but missing their own dependencies)
    # only if we are on a GitHub Action server, because this remove the plugins from the Qt directory
    echo '---- Remove undeployable Qt plugins'
    sudo rm $QT_ROOT_DIR/plugins/position/libqtposition_nmea.so
    sudo rm $QT_ROOT_DIR/plugins/sqldrivers/libqsqlmimer.so
    sudo rm $QT_ROOT_DIR/plugins/sqldrivers/libqsqlmysql.so
    sudo rm $QT_ROOT_DIR/plugins/sqldrivers/libqsqlodbc.so
    sudo rm $QT_ROOT_DIR/plugins/sqldrivers/libqsqlpsql.so
  fi
fi

## PACKAGE (AppImage) ##########################################################

if [[ $create_package = true ]] ; then
  echo '---- Format appdir'
  mkdir -p bin/usr/bin/
  mkdir -p bin/usr/share/appdata/
  mkdir -p bin/usr/share/applications/
  mkdir -p bin/usr/share/pixmaps/
  mkdir -p bin/usr/share/icons/hicolor/scalable/apps/
  mv bin/$APP_NAME bin/usr/bin/$APP_NAME
  cp assets/linux/$APP_NAME_LOWERCASE.appdata.xml bin/usr/share/appdata/$APP_NAME_LOWERCASE.appdata.xml
  cp assets/linux/$APP_NAME_LOWERCASE.desktop bin/usr/share/applications/$APP_NAME_LOWERCASE.desktop
  cp assets/linux/$APP_NAME_LOWERCASE.svg bin/usr/share/pixmaps/$APP_NAME_LOWERCASE.svg
  cp assets/linux/$APP_NAME_LOWERCASE.svg  bin/usr/share/icons/hicolor/scalable/apps/$APP_NAME_LOWERCASE.svg

  echo '---- Running AppImage packager'
  ./contribs/deploy/linuxdeploy-x86_64.AppImage --appdir bin --plugin qt --output appimage
  mv $APP_NAME-x86_64.AppImage $APP_NAME-$APP_VERSION-linux64.AppImage

  #echo '---- Installation directory content recap (after linuxdeploy):'
  #find bin/
fi

## PACKAGE (archive) ###########################################################

if [[ $create_package = true ]] ; then
  echo '---- Reorganize appdir into a regular directory'
  mkdir bin/$APP_NAME/
  mv bin/usr/bin/* bin/$APP_NAME/
  mv bin/usr/lib/* bin/$APP_NAME/
  mv bin/usr/plugins bin/$APP_NAME/
  mv bin/usr/qml bin/$APP_NAME/
  mv bin/usr/share/appdata/$APP_NAME_LOWERCASE.appdata.xml bin/$APP_NAME/
  mv bin/usr/share/applications/$APP_NAME_LOWERCASE.desktop bin/$APP_NAME/
  mv bin/usr/share/pixmaps/$APP_NAME_LOWERCASE.svg bin/$APP_NAME/
  printf '[Paths]\nPrefix = .\nPlugins = plugins\nImports = qml\n' > bin/$APP_NAME/qt.conf
  printf '#!/bin/sh\nappname=`basename $0 | sed s,\.sh$,,`\ndirname=`dirname $0`\nexport LD_LIBRARY_PATH=$dirname\n$dirname/$appname' > bin/$APP_NAME/$APP_NAME_LOWERCASE.sh
  chmod +x bin/$APP_NAME/$APP_NAME_LOWERCASE.sh

  echo '---- Compressing package'
  cd bin
  tar zcvf ../$APP_NAME-$APP_VERSION-linux64.tar.gz $APP_NAME/
fi

## UPLOAD ######################################################################

if [[ $upload_package = true ]] ; then
  printf "---- Uploading to transfer.sh"
  curl --upload-file $APP_NAME*.tar.gz https://transfer.sh/$APP_NAME-$APP_VERSION-git$GIT_VERSION-linux64.tar.gz
  printf "\n"
  curl --upload-file $APP_NAME*.AppImage https://transfer.sh/$APP_NAME-$APP_VERSION-git$GIT_VERSION-linux64.AppImage
  printf "\n"
fi
