#!/bin/bash

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

echo
echo "Android ARMv7"
mkdir -p build-maplibre-native-qt-android_armv7
$Qt6_DIR_BASE/android_armv7/bin/qt-cmake \
    -S  maplibre-native-qt \
    -B build-maplibre-native-qt-android_armv7 \
    -G Ninja \
    -DBUILD_TESTING=OFF \
    -DCMAKE_C_COMPILER_LAUNCHER="ccache" \
    -DCMAKE_CXX_COMPILER_LAUNCHER="ccache" \
    -DCMAKE_PREFIX_PATH=$Qt6_DIR_BASE/android_armv7 \
    -DCMAKE_INSTALL_PREFIX=$Qt6_DIR_BASE/android_armv7
cmake --build build-maplibre-native-qt-android_armv7
cmake --install build-maplibre-native-qt-android_armv7

echo
echo "Android ARM64"
mkdir -p build-maplibre-native-qt-android_arm64_v8a
$Qt6_DIR_BASE/android_arm64_v8a/bin/qt-cmake \
    -S  maplibre-native-qt \
    -B build-maplibre-native-qt-android_arm64_v8a \
    -G Ninja \
    -DBUILD_TESTING=OFF \
    -DCMAKE_C_COMPILER_LAUNCHER="ccache" \
    -DCMAKE_CXX_COMPILER_LAUNCHER="ccache" \
    -DCMAKE_PREFIX_PATH=$Qt6_DIR_BASE/android_arm64_v8a \
    -DCMAKE_INSTALL_PREFIX=$Qt6_DIR_BASE/android_arm64_v8a
cmake --build build-maplibre-native-qt-android_arm64_v8a
cmake --install build-maplibre-native-qt-android_arm64_v8a


echo
echo "Android X86"
mkdir -p build-maplibre-native-qt-android_x86
$Qt6_DIR_BASE/android_x86/bin/qt-cmake \
    -S  maplibre-native-qt \
    -B build-maplibre-native-qt-android_x86 \
    -G Ninja \
    -DBUILD_TESTING=OFF \
    -DCMAKE_C_COMPILER_LAUNCHER="ccache" \
    -DCMAKE_CXX_COMPILER_LAUNCHER="ccache" \
    -DCMAKE_PREFIX_PATH=$Qt6_DIR_BASE/android_x86 \
    -DCMAKE_INSTALL_PREFIX=$Qt6_DIR_BASE/android_x86
cmake --build build-maplibre-native-qt-android_x86
cmake --install build-maplibre-native-qt-android_x86


echo
echo "Android X86_64"
mkdir -p build-maplibre-native-qt-android_x86_64
$Qt6_DIR_BASE/android_x86_64/bin/qt-cmake \
    -S  maplibre-native-qt \
    -B build-maplibre-native-qt-android_x86_64 \
    -G Ninja \
    -DBUILD_TESTING=OFF \
    -DCMAKE_C_COMPILER_LAUNCHER="ccache" \
    -DCMAKE_CXX_COMPILER_LAUNCHER="ccache" \
    -DCMAKE_PREFIX_PATH=$Qt6_DIR_BASE/android_x86_64 \
    -DCMAKE_INSTALL_PREFIX=$Qt6_DIR_BASE/android_x86_64
cmake --build build-maplibre-native-qt-android_x86_64
cmake --install build-maplibre-native-qt-android_x86_64
