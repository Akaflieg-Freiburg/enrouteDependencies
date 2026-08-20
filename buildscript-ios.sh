#!/bin/bash

# Fail on first error
set -e
installDir=Qt/$(basename "$Qt6_DIR_BASE")/ios
simStageDir=build-iOS-simulator-stage

# Qt for iOS ships one fat static library per module that carries an arm64 slice for
# the device and an x86_64 slice for the simulator; there is no arm64 simulator slice,
# so the simulator runs x86_64 (under Rosetta on Apple Silicon). Note that a fat archive
# cannot hold two arm64 slices, which is why Apple invented XCFrameworks and why Qt
# picks x86_64 here.
#
# Mirror that layout: build every library twice - arm64 against the iphoneos SDK and
# x86_64 against the iphonesimulator SDK - and lipo the two archives together. A single
# install prefix then serves both the "Qt for iOS" and the "Qt for iOS Simulator" kit.
#
# Do NOT try to get there by passing -DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" to one
# build: that compiles both slices against the *same* SDK, producing an x86_64-ios
# object that ld refuses to link, so every CMake check that links an executable fails.

buildFor() # $1 = sdk (iphoneos|iphonesimulator), $2 = arch, $3 = install prefix
{
    sdk=$1
    arch=$2
    prefix=$3
    suffix=$sdk-$arch

    echo
    echo "zlib - static for $arch on $sdk"

    $Qt6_DIR_BASE/ios/bin/qt-cmake \
        -G Ninja  \
        -S zlib \
        -B build-zlib-$suffix \
        -DCMAKE_OSX_SYSROOT=$sdk \
        -DCMAKE_OSX_ARCHITECTURES="$arch" \
        -DCMAKE_INSTALL_PREFIX=$prefix \
        -DCMAKE_CXX_FLAGS="-Wno-macro-redefined" \
        -DCMAKE_C_FLAGS="-Wno-macro-redefined"
    cmake --build build-zlib-$suffix
    cmake --install build-zlib-$suffix

    # Delete dynamic libraries, which create trouble under iOS
    rm -f $prefix/lib/libz*dylib

    # libzip needs the zlib built above. Point Qt's toolchain at our install prefix
    # rather than copying zlib into the Qt installation: QT_ADDITIONAL_PACKAGES_PREFIX_PATH
    # extends both CMAKE_PREFIX_PATH and CMAKE_FIND_ROOT_PATH, which cross-compiling needs.

    echo
    echo "libzip - static for $arch on $sdk"

    $Qt6_DIR_BASE/ios/bin/qt-cmake \
        -G Ninja  \
        -S libzip \
        -B build-libzip-$suffix \
        -DBUILD_DOC=OFF \
        -DBUILD_EXAMPLES=OFF \
        -DBUILD_REGRESS=OFF \
        -DBUILD_SHARED_LIBS=OFF \
        -DBUILD_TOOLS=OFF \
        -DENABLE_BZIP2=OFF \
        -DENABLE_LZMA=OFF \
        -DENABLE_ZSTD=OFF \
        -DCMAKE_OSX_SYSROOT=$sdk \
        -DCMAKE_OSX_ARCHITECTURES="$arch" \
        -DQT_ADDITIONAL_PACKAGES_PREFIX_PATH="$PWD/$prefix" \
        -DCMAKE_INSTALL_PREFIX=$prefix
    cmake --build build-libzip-$suffix
    cmake --install build-libzip-$suffix

    echo
    echo "maplibre - static for $arch on $sdk"

    $Qt6_DIR_BASE/ios/bin/qt-cmake \
        -S maplibre-native-qt-flat \
        -B build-maplibre-native-qt-$suffix \
        -G"Ninja Multi-Config" \
        -DCMAKE_CONFIGURATION_TYPES="Release;Debug" \
        -DCMAKE_OSX_SYSROOT=$sdk \
        -DCMAKE_OSX_ARCHITECTURES="$arch" \
        -DCMAKE_INSTALL_PREFIX=$prefix
    cmake --build build-maplibre-native-qt-$suffix
    cmake --install build-maplibre-native-qt-$suffix
}

# The device build owns the install prefix: headers, CMake package files and pkg-config
# files are architecture independent, so they are taken from this pass. The simulator
# build only contributes its static archives, and goes to a scratch prefix.
rm -rf $simStageDir
buildFor iphoneos arm64 $installDir
buildFor iphonesimulator x86_64 $simStageDir

echo
echo "merge the simulator slices into the installed libraries"

# Walk the whole staging tree, not just lib/*.a: the maplibre Qt plugins live under
# plugins/ and qml/, and Qt links the plugin _init object files directly. Missing one of
# those is not a link error - ld just prints "ignoring file ... found architecture arm64,
# required architecture x86_64" and drops it, so the simulator build silently loses the
# plugin and the map stays blank at runtime. Merge .o files as well as .a archives.
while IFS= read -r simFile; do
    relPath=${simFile#"$simStageDir/"}
    deviceFile=$installDir/$relPath
    if [ ! -f "$deviceFile" ]; then
        echo "  WARNING: $relPath has no device counterpart, skipping"
        continue
    fi

    # Take the arm64 slice from whatever is installed, so that re-running the merge over
    # an already merged prefix is a no-op rather than a "duplicate architecture" error.
    deviceArm64=$(mktemp)
    if lipo -archs "$deviceFile" | grep -qw x86_64; then
        lipo -thin arm64 "$deviceFile" -output "$deviceArm64"
    else
        cp "$deviceFile" "$deviceArm64"
    fi
    lipo -create "$deviceArm64" "$simFile" -output "$deviceFile"
    rm -f "$deviceArm64"

    echo "  $relPath: $(lipo -archs "$deviceFile")"
done < <(find "$simStageDir" \( -name "*.a" -o -name "*.o" \))
