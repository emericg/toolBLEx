#!/usr/bin/env bash

export APP_NAME="toolBLEx"
export APP_VERSION=0.14
export GIT_VERSION=$(git rev-parse --short HEAD)

echo "> $APP_NAME packager (Windows x86_64) [v$APP_VERSION]"

## CHECKS ######################################################################

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

## APP INSTALL #################################################################

if [[ $make_install = true ]] ; then
  echo '---- Running make install'
  make INSTALL_ROOT=bin/ install

  #echo '---- Installation directory content recap (after make install):'
  #find bin/
fi

## APP DEPLOY ##################################################################

if [[ $create_package = true ]] ; then
  if [[ -v QT_ROOT_DIR ]]; then
    # cleanup undeployable Qt plugins (present, but missing their own dependencies)
    # only if we are on a GitHub Action server, because this remove the plugins from the Qt directory
    echo '---- Remove undeployable Qt plugins'
    sudo rm $QT_ROOT_DIR/plugins/position/qtposition_nmea.dll
  fi
fi

echo '---- Running windeployqt'
windeployqt bin/ --qmldir qml/

#echo '---- Installation directory content recap (after windeployqt):'
#find bin/

#echo '---- Clean installation directory'
#rm bin/.gitkeep
#rm bin/qmltooling
#rm bin/generic

mv bin $APP_NAME

## PACKAGE (zip) ###############################################################

if [[ $create_package = true ]] ; then
  echo '---- Compressing package'
  7z a $APP_NAME-$APP_VERSION-win64.zip $APP_NAME
fi

## PACKAGE (NSIS) ##############################################################

if [[ $create_package = true ]] ; then
  echo '---- Creating installer'
  mv $APP_NAME assets/windows/$APP_NAME
  makensis assets/windows/setup.nsi
  mv assets/windows/*.exe $APP_NAME-$APP_VERSION-win64.exe
fi

## UPLOAD ######################################################################

if [[ $upload_package = true ]] ; then
  printf "---- Uploading to transfer.sh"
  curl --upload-file $APP_NAME*.zip https://transfer.sh/$APP_NAME-$APP_VERSION-git$GIT_VERSION-win64.zip
  printf "\n"
  curl --upload-file $APP_NAME*.exe https://transfer.sh/$APP_NAME-$APP_VERSION-git$GIT_VERSION-win64.exe
  printf "\n"
fi
