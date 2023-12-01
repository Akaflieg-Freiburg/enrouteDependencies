#!/bin/bash

# Fail on first error
set -e

echo
echo "libzip for macOS"

$Qt6_DIR_BASE/macos/bin/qt-cmake \
    -G Ninja  \
    -S libzip \
    -B build-libzip-macOS \
    -DENABLE_ZSTD=OFF \
    -DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" \
    -DCMAKE_INSTALL_PREFIX=$Qt6_DIR_BASE/macos \ 
cmake --build build-libzip-macOS
cmake --install build-libzip-macOS

echo
echo "maplibre for macOS"

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
