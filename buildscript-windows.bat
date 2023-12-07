#!/bin/bash

# Fail on first error
set -e

installDir=Qt/$(basename "$Qt6_DIR_BASE")/msvc2019_64

echo
echo "Windows Desktop"

$Qt6_DIR_BASE/msvc2019_64/bin/qt-cmake \
    -S maplibre-native-qt \
    -B build-maplibre-native-qt-windows \
    -G Ninja \
    -DBUILD_TESTING=OFF \
    -DCMAKE_C_COMPILER_LAUNCHER="ccache" \
    -DCMAKE_CXX_COMPILER_LAUNCHER="ccache" \
    -DCMAKE_PREFIX_PATH=$Qt6_DIR_BASE/msvc2019_64 \
    -DCMAKE_INSTALL_PREFIX=$installDir
cmake --build build-maplibre-native-qt-windows
cmake --install build-maplibre-native-qt-windows
