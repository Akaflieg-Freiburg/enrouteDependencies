#!/bin/bash

export Qt6_DIR_BASE=/home/kebekus/Software/buildsystems/Qt/6.6.0

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
