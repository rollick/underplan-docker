#!/bin/bash

#LOG functions
f_LOG() {
  echo "`date`:$@"
}

f_INFO() {
  f_LOG "INFO: $@"
}

f_WARNING() {
  f_LOG "WARNING: $@"
}

f_DEBUG() {
  if [ $DEBUG ];
  then
    f_LOG "DEBUG: $@"
  fi
}

usage () {
  echo "Usage of $0"
  echo "-a app_name: Used to set directory names"
  echo "-g repo_url: Git repo from which code is fetched"
  echo "-p environment: Used to set the postfix on directory names"
  echo "-f: Force deploy regardless of code changes (optional)"
  echo "-d: Show extra debug output (optional)"
  # echo Add something useful here.
}

PREFIX=""
POSTFIX=""

while getopts "a:p:g:fdh" option; do
  case "$option" in
    a)  PREFIX="$OPTARG" ;;
    p)  POSTFIX="$OPTARG" ;;
    g)  REPO_URL="$OPTARG" ;;
    f)  FORCE=true ;;
    d)  DEBUG=true ;;
    h)  # it's always useful to provide some help 
        usage
        exit 0 
        ;;
    :)  echo "Error: -$option requires an argument" 
        usage
        exit 1
        ;;
    ?)  echo "Error: unknown option -$option" 
        usage
        exit 1
        ;;
  esac
done  

if [ -z $PREFIX ];
then
  f_WARNING "No app name passed with -a option. Exiting."
  usage
  exit 1
fi

APP_NAME="${PREFIX}${POSTFIX}"
WEB_ROOT="/site-data"
SCRIPTS_PATH="/root/scripts"

APP_SRC_PATH="${WEB_ROOT}/${APP_NAME}_src"
APP_STARTUP="${SCRIPTS_PATH}/${APP_NAME}.sh"
LOCK_FILE="${SCRIPTS_PATH}/deploy_${APP_NAME}.lck"
# using mrt now for deploy
METEOR="`which mrt`" 
NPM="`which npm`"

BUNDLE_PATH="${WEB_ROOT}/bundle_${APP_NAME}"
BUNDLE_TAR_PATH="${WEB_ROOT}/bundle_${APP_NAME}.tgz"
BUNDLE_TAR_PREVIOUS_PATH="${WEB_ROOT}/bundle_${APP_NAME}_previous.tgz"
APP_PATH="${WEB_ROOT}/${APP_NAME}"
APP_PREVIOUS_PATH="${WEB_ROOT}/${APP_NAME}_previous"

if [ -f $LOCK_FILE ];
then
  f_INFO "App is currently being deployed. Exiting."
else
  touch $LOCK_FILE;
fi

if [ ! -f $METEOR ];
then
  f_WARNING "Meteor executable does not exist. Exiting."
  exit 1
fi

if [ ! -f $NPM ];
then
  f_WARNING "Npm executable does not exist. Exiting."
  exit 1
fi

if [ ! -d "$APP_SRC_PATH/.git" ];
then
  f_INFO "Fetching source..."
  git clone $REPO_URL $APP_SRC_PATH
fi

f_INFO "Checking out master branch..."
cd $APP_SRC_PATH && git reset --hard && git checkout master

if [ ! -d "$APP_SRC_PATH" ];
then
  echo `ls $WEB_ROOT`
  f_WARNING "App source not found: ${APP_SRC_PATH} Exiting."
  exit 1
fi

cd $APP_SRC_PATH
CC="`git rev-parse HEAD`"
git reset --hard
git clean -dxf
git pull
NC="`git rev-parse HEAD`"

if [[ "$CC" = "$NC" && ! $FORCE ]];
then 
  f_INFO "No changes to code. Move along now..."
else
  if [ $FORCE ];
  then
    f_INFO "Forced deploy"
  else
    f_INFO "Code has changed."
  fi

  if [ -f $BUNDLE_TAR_PATH ];
  then
    mv $BUNDLE_TAR_PATH $BUNDLE_TAR_PREVIOUS_PATH
  fi

  f_INFO "Adding minifiers package"
  (echo && echo "minifiers") >> .meteor/packages

  f_DEBUG "Bundling app: ${METEOR} bundle ${BUNDLE_TAR_PATH}"
  $METEOR bundle $BUNDLE_TAR_PATH

  f_DEBUG "Checking if file exists at: ${BUNDLE_TAR_PATH}"
  if [ -f $BUNDLE_TAR_PATH ];
  then
    f_INFO "Uncompressing app"
    rm -Rf $BUNDLE_PATH
    mkdir $BUNDLE_PATH && tar -zxf $BUNDLE_TAR_PATH --strip 1 -C $BUNDLE_PATH
  else
    f_WARNING "What?! No bundle file."
    rm -f $LOCK_FILE;

    exit 1
  fi

  if [ -f "${BUNDLE_PATH}/main.js" ];
  then
    f_INFO "Updating Fibers"
    cd $BUNDLE_PATH/programs/server
    $NPM uninstall fibers
    $NPM install fibers@1.0.1

    f_INFO "Replacing existing bundle."
    f_DEBUG "Trying: cd ${WEB_ROOT}"
    cd $WEB_ROOT

    f_DEBUG "rm -Rf ${APP_PREVIOUS_PATH}"
    rm -Rf $APP_PREVIOUS_PATH

    f_DEBUG "mv ${APP_PATH} ${APP_PREVIOUS_PATH}"
    mv $APP_PATH $APP_PREVIOUS_PATH

    f_DEBUG "mv ${BUNDLE_PATH} ${APP_PATH}"
    mv $BUNDLE_PATH $APP_PATH

    f_INFO "Deploy complete."
  else
    f_WARNING "Bundle does not exist. Something went wrong :-("
  fi
fi

rm -f $LOCK_FILE
