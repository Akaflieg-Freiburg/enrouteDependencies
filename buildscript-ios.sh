#!/bin/bash

# Fail on first error
set -e


echo
echo "zlib - static for arm64 and x86_64 on iOS"

$Qt6_DIR_BASE/ios/bin/qt-cmake \
    -G Ninja  \
    -S zlib \
    -B build-zlib-iOS \
    -DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" \
    -DCMAKE_INSTALL_PREFIX=$Qt6_DIR_BASE/ios
cmake --build build-zlib-iOS
cmake --install build-zlib-iOS

echo
echo "libzip - static for arm64 and x86_64 on iOS"

$Qt6_DIR_BASE/ios/bin/qt-cmake \
    -G Ninja  \
    -S libzip \
    -B build-libzip-iOS \
    -DBUILD_DOC=OFF \
    -DBUILD_EXAMPLES=OFF \
    -DBUILD_REGRESS=OFF \
    -DBUILD_SHARED_LIBS=OFF \
    -DBUILD_TOOLS=OFF \
    -DENABLE_BZIP2=OFF \
    -DENABLE_LZMA=OFF \
    -DENABLE_ZSTD=OFF \
    -DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" \
    -DCMAKE_INSTALL_PREFIX=$Qt6_DIR_BASE/ios
cmake --build build-libzip-iOS
cmake --install build-libzip-iOS
