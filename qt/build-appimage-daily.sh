#! /bin/bash

set -xe

echo $APP_NAME

useradd user -u ${1:-1000}

mkdir /app
mkdir /build

#Set Qt-5.12
export QT_BASE_DIR=/opt/qt5.12.10
export QTDIR=$QT_BASE_DIR
export PATH=$QT_BASE_DIR/bin:$PATH
export LD_LIBRARY_PATH=$QT_BASE_DIR/lib/x86_64-linux-gnu:$QT_BASE_DIR/lib:$LD_LIBRARY_PATH
export PKG_CONFIG_PATH=$QT_BASE_DIR/lib/pkgconfig:$PKG_CONFIG_PATH

#Build client
cd /build
cp -rf /data .
mkdir build-client
cd build-client
cmake -D CMAKE_INSTALL_PREFIX=/usr \
    /build/data
make -j4
make DESTDIR=/app install

# Move stuff around
cd /app

#mv ./usr/lib/x86_64-linux-gnu/* ./usr/lib/
rm -rf ./usr/lib/cmake
rm -rf ./usr/include
rm -rf ./usr/mkspecs
rm -rf ./usr/lib/x86_64-linux-gnu/

DESKTOP_FILE=$(ls /app/usr/share/applications/*.desktop)
cp ./usr/share/icons/hicolor/scalable/apps/MultiSlider.svg . # Workaround for linuxeployqt bug, FIXME

# Because distros need to get their shit together
cp -R /usr/lib/x86_64-linux-gnu/libssl.so* ./usr/lib/
cp -R /usr/lib/x86_64-linux-gnu/libcrypto.so* ./usr/lib/
cp -P /usr/local/lib/libssl.so* ./usr/lib/
cp -P /usr/local/lib/libcrypto.so* ./usr/lib/

# NSS fun
cp -P -r /usr/lib/x86_64-linux-gnu/nss ./usr/lib/

# Use linuxdeployqt to deploy
cd /build
wget --ca-directory=/etc/ssl/certs -c "https://github.com/probonopd/linuxdeployqt/releases/download/continuous/linuxdeployqt-continuous-x86_64.AppImage"
chmod a+x linuxdeployqt*.AppImage
./linuxdeployqt-continuous-x86_64.AppImage --appimage-extract
rm ./linuxdeployqt-continuous-x86_64.AppImage
unset QTDIR; unset QT_PLUGIN_PATH ; unset LD_LIBRARY_PATH
export LD_LIBRARY_PATH=/app/usr/lib/

# AppRun
./squashfs-root/AppRun ${DESKTOP_FILE} -bundle-non-qt-libs #-qmldir=/build/desktop/src/gui

# Build AppImage
./squashfs-root/AppRun ${DESKTOP_FILE} -appimage

#export VERSION_MAJOR=$(cat build-client/version.h | grep MIRALL_VERSION_MAJOR | cut -d ' ' -f 3)
#export VERSION_MINOR=$(cat build-client/version.h | grep MIRALL_VERSION_MINOR | cut -d ' ' -f 3)
#export VERSION_PATCH=$(cat build-client/version.h | grep MIRALL_VERSION_PATCH | cut -d ' ' -f 3)
#export VERSION_BUILD=$(cat build-client/version.h | grep MIRALL_VERSION_BUILD | cut -d ' ' -f 3)

ls -l
mv ${APP_NAME}*.AppImage ${APP_NAME}-${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH}.${VERSION_BUILD}-daily-x86_64.AppImage

mv ${APP_NAME}*.AppImage /output/${APP_NAME}
chown user /output/${APP_NAME}/${APP_NAME}*.AppImage
ls -l /output/
