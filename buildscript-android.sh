#!/bin/bash

# Fail on first error
set -e


for PLATFORM in android_armv7 android_arm64_v8a android_x86 android_x86_64
do
	echo
	echo "libzip - static for arm64 and x86_64 on iOS"

	$Qt6_DIR_BASE/$PLATFORM/bin/qt-cmake \
    	-G Ninja  \
	    -S libzip \
    	-B build-libzip-$PLATFORM \
	    -DBUILD_DOC=OFF \
    	-DBUILD_EXAMPLES=OFF \
	    -DBUILD_REGRESS=OFF \
    	-DBUILD_SHARED_LIBS=OFF \
	    -DBUILD_TOOLS=OFF \
    	-DENABLE_BZIP2=OFF \
	    -DENABLE_LZMA=OFF \
    	-DENABLE_ZSTD=OFF \
    	-DCMAKE_INSTALL_PREFIX=$Qt6_DIR_BASE/$PLATFORM
	cmake --build build-libzip-$PLATFORM
	cmake --install build-libzip-$PLATFORM


    echo
    echo "Android ARMv7"

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
