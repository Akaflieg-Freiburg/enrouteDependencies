#!/bin/bash

# Fail on first error
set -e

installDir=Qt/$(basename "$Qt6_DIR_BASE")/gcc_64

echo
echo "Linux Desktop"

$Qt6_DIR_BASE/gcc_64/bin/qt-cmake \
    -S maplibre-native-qt \
    -B build-maplibre-native-qt-linux \
    -G Ninja \
    -DMLN_QT_WITH_INTERNAL_ICU=ON \
    -DBUILD_TESTING=OFF \
    -DCMAKE_C_COMPILER_LAUNCHER="ccache" \
    -DCMAKE_CXX_COMPILER_LAUNCHER="ccache" \
    -DCMAKE_PREFIX_PATH=$Qt6_DIR_BASE/gcc_64 \
    -DCMAKE_INSTALL_PREFIX=$installDir
cmake --build build-maplibre-native-qt-linux
cmake --install build-maplibre-native-qt-linux
