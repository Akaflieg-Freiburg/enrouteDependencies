#!/bin/bash

# Fail on first error
set -e


#
# The Linux Desktop binary needs MLN_QT_WITH_INTERNAL_ICU
#

echo
echo "Linux Desktop"
mkdir -p build-maplibre-native-qt-linux
$Qt6_DIR_BASE/gcc_64/bin/qt-cmake \
    -S  maplibre-native-qt \
    -B build-maplibre-native-qt-linux \
    -G Ninja \
    -DMLN_QT_WITH_INTERNAL_ICU=ON \
    -DBUILD_TESTING=OFF \
    -DCMAKE_C_COMPILER_LAUNCHER="ccache" \
    -DCMAKE_CXX_COMPILER_LAUNCHER="ccache" \
    -DCMAKE_PREFIX_PATH=$Qt6_DIR_BASE/gcc_64 \
    -DCMAKE_INSTALL_PREFIX=$Qt6_DIR_BASE/gcc_64
cmake --build build-maplibre-native-qt-linux
cmake --install build-maplibre-native-qt-linux


#
# The Android binaries all need identical CMAKE configurations
#

for PLATFORM in android_armv7 android_arm64_v8a android_x86 android_x86_64
do
    echo
    echo "Android ARMv7"
    mkdir -p build-maplibre-native-qt-$PLATFORM
    $Qt6_DIR_BASE/$PLATFORM/bin/qt-cmake \
	-S  maplibre-native-qt \
	-B build-maplibre-native-qt-$PLATFORM \
	-G Ninja \
	-DBUILD_TESTING=OFF \
	-DCMAKE_C_COMPILER_LAUNCHER="ccache" \
	-DCMAKE_CXX_COMPILER_LAUNCHER="ccache" \
	-DCMAKE_PREFIX_PATH=$Qt6_DIR_BASE/$PLATFORM \
	-DCMAKE_INSTALL_PREFIX=$Qt6_DIR_BASE/$PLATFORM
    cmake --build build-maplibre-native-qt-$PLATFORM
    cmake --install build-maplibre-native-qt-$PLATFORM
done
