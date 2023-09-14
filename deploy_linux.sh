#!/usr/bin/env bash

echo "> toolBLEx packager (Linux x86_64)"

export APP_NAME="toolBLEx";
export APP_VERSION=0.8;
export GIT_VERSION=$(git rev-parse --short HEAD);

## CHECKS ######################################################################

if [ "$(id -u)" == "0" ]; then
  echo "This script MUST NOT be run as root" 1>&2
  exit 1
fi

if [ ${PWD##*/} != "toolBLEx" ]; then
  echo "This script MUST be run from the toolBLEx/ directory"
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

## APP INSTALL #################################################################

if [[ $make_install = true ]] ; then
  echo '---- Running make install'
  make INSTALL_ROOT=appdir/ install;

  #echo '---- Installation directory content recap:'
  #find appdir/;
fi

## DEPLOY ######################################################################

unset LD_LIBRARY_PATH; #unset QT_PLUGIN_PATH; #unset QTDIR;

if [[ $use_contribs = true ]] ; then
  export LD_LIBRARY_PATH=$(pwd)/contribs/src/env/linux_x86_64/usr/lib/:/usr/lib;
else
  export LD_LIBRARY_PATH=/usr/lib/;
fi
USRDIR=/usr;
if [ -d appdir/usr/local ]; then
  USRDIR=/usr/local;
fi
if [ -z "$QTDIR" ]; then
  QTDIR=/usr/lib/qt;
fi

echo '---- Downloading linuxdeploy + plugins'
if [ ! -x contribs/deploy/linuxdeploy-x86_64.AppImage.AppImage ]; then
  wget -c -nv "https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage" -P contribs/deploy/;
  wget -c -nv "https://github.com/linuxdeploy/linuxdeploy-plugin-appimage/releases/download/continuous/linuxdeploy-plugin-appimage-x86_64.AppImage" -P contribs/deploy/;
  wget -c -nv "https://github.com/linuxdeploy/linuxdeploy-plugin-qt/releases/download/continuous/linuxdeploy-plugin-qt-x86_64.AppImage" -P contribs/deploy/;
fi
chmod a+x contribs/deploy/linuxdeploy-x86_64.AppImage;
chmod a+x contribs/deploy/linuxdeploy-plugin-appimage-x86_64.AppImage;
chmod a+x contribs/deploy/linuxdeploy-plugin-qt-x86_64.AppImage;

# linuxdeploy settings
export QML_SOURCES_PATHS="$(pwd)/qml/"
export EXTRA_QT_PLUGINS="svg;"

#echo '---- Installation directory content recap:'
#find appdir/;

## PACKAGE (AppImage) ##########################################################

if [[ $create_package = true ]] ; then
  echo '---- Running AppImage packager'
  ./contribs/deploy/linuxdeploy-x86_64.AppImage --appdir appdir --plugin qt --output appimage
fi

## PACKAGE (ZIP) ###############################################################

# TODO

## UPLOAD ######################################################################

if [[ $upload_package = true ]] ; then
  printf "---- Uploading to transfer.sh"
  find appdir -executable -type f -exec ldd {} \; | grep " => $USRDIR" | cut -d " " -f 2-3 | sort | uniq;
  curl --upload-file $APP_NAME*.AppImage https://transfer.sh/$APP_NAME-$APP_VERSION-git$GIT_VERSION-linux64.AppImage;
  printf "\n"
fi
