#!/bin/bash

# Fail on first error
set -e

rm -rf QtAndroid

for PLATFORM in arm64-v8a x86_64 x86 armeabi-v7a
do
	installDir=../QtAndroid/$PLATFORM

	echo
	echo "Qt $PLATFORM"

	rm -rf build-qt-$PLATFORM
	mkdir build-qt-$PLATFORM
	cd build-qt-$PLATFORM
	$HOME/Software/buildsystems/Qt/6.8.2/Src/configure \
	    -prefix $installDir \
	    -qt-host-path $HOME/Software/buildsystems/Qt/6.8.2/gcc_64 \
	    -android-abis $PLATFORM \
	    -android-sdk $ANDROID_SDK_ROOT \
	    -android-ndk $ANDROID_NDK_ROOT \
	    -ccache \
	    -submodules qt5compat,qtconnectivity,qthttpserver,qtlocation,qtsensors,qtspeech,qtsvg,qttranslations,qtwebview
	ninja install
	cd ..
done

mv QtAndroid/arm64-v8a QtAndroid/android_arm64_v8a
mv QtAndroid/x86_64 QtAndroid/android_x86_64
mv QtAndroid/x86 QtAndroid/android_x86
mv QtAndroid/armeabi-v7a QtAndroid/android_armv7

for PLATFORM in android_armv7 android_arm64_v8a android_x86 android_x86_64
do
	installDir=QtAndroid/$PLATFORM

	echo
	echo "libzip - static for $PLATFORM"

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
    	-DCMAKE_INSTALL_PREFIX=$installDir
	cmake --build build-libzip-$PLATFORM
	cmake --install build-libzip-$PLATFORM


    echo
    echo "maplibre-native-qt - for $PLATFORMARM"

    $Qt6_DIR_BASE/$PLATFORM/bin/qt-cmake \
		-S maplibre-native-qt \
		-B build-maplibre-native-qt-$PLATFORM \
		-G Ninja \
		-DBUILD_TESTING=OFF \
		-DCMAKE_C_COMPILER_LAUNCHER="ccache" \
		-DCMAKE_CXX_COMPILER_LAUNCHER="ccache" \
		-DCMAKE_PREFIX_PATH=$Qt6_DIR_BASE/$PLATFORM \
		-DCMAKE_INSTALL_PREFIX=$installDir
    cmake --build build-maplibre-native-qt-$PLATFORM
    cmake --install build-maplibre-native-qt-$PLATFORM
done
