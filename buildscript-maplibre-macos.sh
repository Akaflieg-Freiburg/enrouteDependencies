#!/bin/bash

# Fail on first error
set -e


#
# macOS
#

echo
echo "macOS Desktop"
mkdir -p build-maplibre-native-qt-macOS
$Qt6_DIR_BASE/macos/bin/qt-cmake \
    -S  maplibre-native-qt \
    -B build-maplibre-native-qt-macOS \
    -G Ninja \
    -DCMAKE_OSX_ARCHITECTURES="x86_64;arm64" \
    -DBUILD_TESTING=OFF \
    -DCMAKE_C_COMPILER_LAUNCHER="ccache" \
    -DCMAKE_CXX_COMPILER_LAUNCHER="ccache" \
    -DCMAKE_INSTALL_PREFIX=$Qt6_DIR_BASE/macos
cmake --build build-maplibre-native-qt-macOS
cmake --install build-maplibre-native-qt-macOS


#
# iOS
#

echo
echo "iOS"
mkdir -p build-maplibre-native-qt-iOS
$Qt6_DIR_BASE/macos/bin/qt-cmake \
    -S  maplibre-native-qt \
    -B build-maplibre-native-qt-iOS \
    -G "Ninja Multi-Config" \
    -DCMAKE_CONFIGURATION_TYPES="Release;Debug" \
    -DBUILD_TESTING=OFF \
    -DCMAKE_C_COMPILER_LAUNCHER="ccache" \
    -DCMAKE_CXX_COMPILER_LAUNCHER="ccache" \
    -DCMAKE_INSTALL_PREFIX=$Qt6_DIR_BASE/ios
cmake --build build-maplibre-native-qt-iOS
cmake --install build-maplibre-native-qt-iOS


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
