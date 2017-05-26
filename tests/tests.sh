#!/bin/bash

###############################################################################
# Build the sample Qt Widgets Application that comes with Qt Creator
###############################################################################

cd tests/QtWidgetsApplication/
if [ -e build/ ] ; then
  rm -rf build/
fi
mkdir build
cd build/
qmake ../QtWidgetsApplication.pro
make -j2

cd ../../../

###############################################################################
# Build the sample Qt Quick Controls 2 Application that comes with Qt Creator
###############################################################################

cd tests/QtQuickControls2Application/
if [ -e build/ ] ; then
  rm -rf build/
fi
mkdir build
cd build/
qmake ../QtQuickControls2Application.pro
make -j2

cd ../../../

###############################################################################
# Build the sample Qt WebEngine Application
###############################################################################

cd tests/QtWebEngineApplication/
if [ -e build/ ] ; then
  rm -rf build/
fi
mkdir build
cd build/
qmake ../QtWebEngineApplication.pro
make -j2

cd ../../../

###############################################################################
# Workaround for:
# https://github.com/probonopd/linuxdeployqt/issues/65
###############################################################################

unset QT_PLUGIN_PATH
unset LD_LIBRARY_PATH
unset QTDIR

###############################################################################
# Test bundling the sample Qt Widgets Application that comes with Qt Creator
###############################################################################

cd tests/QtWidgetsApplication/build/
mkdir -p nonfhs fhs/usr/bin

# enable core dumps
ulimit -c unlimited

cp QtWidgetsApplication nonfhs/
../../../linuxdeployqt-*-x86_64.AppImage nonfhs/QtWidgetsApplication || RESULT=$?
if [ $RESULT -eq 139 ]; then
  echo "FAILURE: linuxdeployqt CRASHED with SIGSEGV -- uploading available core dumps to transfer.sh"
  for dump in $(find -type f -iname "$(cat /proc/sys/kernel/core_pattern | cut -d' ' -f1 | tr -d "|")*"); do
    curl --upload-file $dump https://transfer.sh/$(basename $dump)
  done
  exit $RESULT
fi

ldd nonfhs/QtWidgetsApplication
find nonfhs/
LD_DEBUG=libs nonfhs/QtWidgetsApplication &
sleep 5
killall QtWidgetsApplication && echo "SUCCESS"

cp QtWidgetsApplication fhs/usr/bin/
../../../linuxdeployqt-*-x86_64.AppImage fhs/usr/bin/QtWidgetsApplication
ldd fhs/usr/bin/QtWidgetsApplication
find fhs/
LD_DEBUG=libs fhs/usr/bin/QtWidgetsApplication &
sleep 5
killall QtWidgetsApplication && echo "SUCCESS"

cd ../../../

###############################################################################
# Test bundling the sample Qt Quick Controls 2 Application that comes with Qt Creator
###############################################################################

cd tests/QtQuickControls2Application/build/
mkdir -p nonfhs fhs/usr/bin

cp QtQuickControls2Application nonfhs/
../../../linuxdeployqt-*-x86_64.AppImage nonfhs/QtQuickControls2Application -qmldir=../
../../../linuxdeployqt-*-x86_64.AppImage nonfhs/QtQuickControls2Application -qmldir=../ # FIXME, Workaround for: https://github.com/probonopd/linuxdeployqt/issues/25
ldd nonfhs/QtQuickControls2Application
find nonfhs/
LD_DEBUG=libs nonfhs/QtQuickControls2Application &
sleep 10
killall QtQuickControls2Application && echo "SUCCESS"

cp QtQuickControls2Application fhs/usr/bin/
../../../linuxdeployqt-*-x86_64.AppImage fhs/usr/bin/QtQuickControls2Application -qmldir=../
../../../linuxdeployqt-*-x86_64.AppImage fhs/usr/bin/QtQuickControls2Application -qmldir=../ # FIXME, Workaround for: https://github.com/probonopd/linuxdeployqt/issues/25
ldd fhs/usr/bin/QtQuickControls2Application
find fhs/
LD_DEBUG=libs fhs/usr/bin/QtQuickControls2Application &
sleep 10
killall QtQuickControls2Application && echo "SUCCESS"

cd ../../../

###############################################################################
# Test bundling the sample Qt WebEngine Application
###############################################################################

cd tests/QtWebEngineApplication/build/
mkdir -p nonfhs fhs/usr/bin

cp QtWebEngineApplication nonfhs/
../../../linuxdeployqt-*-x86_64.AppImage nonfhs/QtWebEngineApplication -qmldir=../
../../../linuxdeployqt-*-x86_64.AppImage nonfhs/QtWebEngineApplication -qmldir=../ # FIXME, Workaround for: https://github.com/probonopd/linuxdeployqt/issues/25
ldd nonfhs/QtWebEngineApplication
find nonfhs/
LD_DEBUG=libs nonfhs/QtWebEngineApplication &
sleep 10
killall QtWebEngineApplication && echo "SUCCESS"

cp QtWebEngineApplication fhs/usr/bin/
../../../linuxdeployqt-*-x86_64.AppImage fhs/usr/bin/QtWebEngineApplication -qmldir=../
../../../linuxdeployqt-*-x86_64.AppImage fhs/usr/bin/QtWebEngineApplication -qmldir=../ # FIXME, Workaround for: https://github.com/probonopd/linuxdeployqt/issues/25
ldd fhs/usr/bin/QtWebEngineApplication
find fhs/
LD_DEBUG=libs fhs/usr/bin/QtWebEngineApplication &
sleep 10
killall QtWebEngineApplication && echo "SUCCESS"

cd ../../../
