#!/bin/bash

# Fail on first error
set -e
installDir=Qt/$(basename "$Qt6_DIR_BASE")/ios


echo
echo "bzip2 - static for arm64 and x86_64 on iOS"

$Qt6_DIR_BASE/ios/bin/qt-cmake \
    -G Ninja  \
    -S bzip2 \
    -B build-bzip2-iOS \
    -DENABLE_APP=OFF \
    -DENABLE_DOCS=OFF \
    -DENABLE_SHARED_LIB=OFF \
    -DENABLE_STATIC_LIB=ON \
    -DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" \
    -DCMAKE_INSTALL_PREFIX=$installDir
cmake --build build-bzip2-iOS
cmake --install build-bzip2-iOS

echo
echo "zlib - static for arm64 and x86_64 on iOS"

$Qt6_DIR_BASE/ios/bin/qt-cmake \
    -G Ninja  \
    -S zlib \
    -B build-zlib-iOS \
    -DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" \
    -DCMAKE_INSTALL_PREFIX=$installDir \
    -DCMAKE_CXX_FLAGS="-Wno-macro-redefined" \
    -DCMAKE_C_FLAGS="-Wno-macro-redefined"
cmake --build build-zlib-iOS
cmake --install build-zlib-iOS

# Delete dynamic libraries, which create trouble under iOS
rm $installDir/lib/libz*dylib


echo
echo "copy static bzip2 and zlib to development directory, so cmake can find it"

cp -rv $installDir $Qt6_DIR_BASE


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
    -DCMAKE_INSTALL_PREFIX=$installDir
cmake --build build-libzip-iOS
cmake --install build-libzip-iOS

echo
echo "maplibre for iOS"

$Qt6_DIR_BASE/ios/bin/qt-cmake \
    -S maplibre-native-qt \
    -B build-maplibre-native-qt-iOS \
    -G"Ninja Multi-Config" \
    -DCMAKE_CONFIGURATION_TYPES="Release;Debug" \
    -DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" \
    -DCMAKE_INSTALL_PREFIX=$installDir
cmake --build build-maplibre-native-qt-iOS
cmake --install build-maplibre-native-qt-iOS
