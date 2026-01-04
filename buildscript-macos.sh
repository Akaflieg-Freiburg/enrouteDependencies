#!/bin/bash

# Fail on first error
set -e

if [[ -z "$Qt6_DIR_BASE" && -d "$HOME/Qt" ]]; then
    latest_qt_dir="$(find "$HOME/Qt" -type f -path "*/macos/bin/qt-cmake" -print 2>/dev/null | sed 's#/macos/bin/qt-cmake$##' | sort -V | tail -n 1)"
    if [[ -n "$latest_qt_dir" ]]; then
        Qt6_DIR_BASE="$latest_qt_dir"
    fi
fi

if [[ -z "$Qt6_DIR_BASE" || ! -x "$Qt6_DIR_BASE/macos/bin/qt-cmake" ]]; then
    echo "Qt6_DIR_BASE is empty or invalid. Set it to the Qt 6 base dir (parent of macos)." >&2
    exit 1
fi

installDir=Qt/$(basename "$Qt6_DIR_BASE")/macos

echo "Using Qt: $(basename "$Qt6_DIR_BASE")"
echo
echo "libzip for macOS"

"$Qt6_DIR_BASE"/macos/bin/qt-cmake \
    -G Ninja  \
    -S libzip \
    -B build-libzip-macOS \
    -DENABLE_LZMA=OFF \
    -DENABLE_ZSTD=OFF \
    -DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" \
    -DCMAKE_INSTALL_PREFIX="$installDir"
cmake --build build-libzip-macOS
cmake --install build-libzip-macOS

echo
echo "maplibre for macOS"

"$Qt6_DIR_BASE"/macos/bin/qt-cmake \
    -S maplibre-native-qt-flat \
    -B build-maplibre-native-qt-macOS \
    -G Ninja \
    -DCMAKE_OSX_ARCHITECTURES="x86_64;arm64" \
    -DBUILD_TESTING=OFF \
    -DCMAKE_C_COMPILER_LAUNCHER="ccache" \
    -DCMAKE_CXX_COMPILER_LAUNCHER="ccache" \
    -DCMAKE_INSTALL_PREFIX="$installDir"
cmake --build build-maplibre-native-qt-macOS
cmake --install build-maplibre-native-qt-macOS
