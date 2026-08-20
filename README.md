[![Compile on Android](https://github.com/Akaflieg-Freiburg/enrouteDependencies/actions/workflows/android.yml/badge.svg)](https://github.com/Akaflieg-Freiburg/enrouteDependencies/actions/workflows/android.yml) [![Compile on iOS](https://github.com/Akaflieg-Freiburg/enrouteDependencies/actions/workflows/ios.yml/badge.svg)](https://github.com/Akaflieg-Freiburg/enrouteDependencies/actions/workflows/ios.yml) [![Compile on Linux](https://github.com/Akaflieg-Freiburg/enrouteDependencies/actions/workflows/linux.yml/badge.svg)](https://github.com/Akaflieg-Freiburg/enrouteDependencies/actions/workflows/linux.yml) [![Compile on macOS](https://github.com/Akaflieg-Freiburg/enrouteDependencies/actions/workflows/macos.yml/badge.svg)](https://github.com/Akaflieg-Freiburg/enrouteDependencies/actions/workflows/macos.yml)

# enrouteDependencies

This repository hosts build scripts for the third-party dependencies of Enroute Flight Navigation:
the maplibre port for Qt, [maplibre-native-qt](https://github.com/maplibre/maplibre-native-qt), and
– on the platforms that need them – static builds of
[libzip](https://github.com/nih-at/libzip) and [zlib](https://github.com/madler/zlib).

The repository also contains [bzip2](https://github.com/libarchive/bzip2) as a submodule, but no
build script compiles it any more. Android, iOS and Windows configure libzip with
`ENABLE_BZIP2=OFF`; macOS leaves libzip's default in place, so the macOS build links the *system*
bzip2 rather than this submodule.

Which libraries are built depends on the target platform.

| Platform | Libraries built                     |
|----------|-------------------------------------|
| Android  | libzip, maplibre-native-qt          |
| iOS      | zlib, libzip, maplibre-native-qt (static, arm64 device + x86_64 simulator) |
| Linux    | maplibre-native-qt                  |
| macOS    | libzip, maplibre-native-qt (universal, arm64 + x86_64) |

The GitHub workflows in this repository run these scripts on every push to `main` and upload the
resulting archives to the rolling `developerBuilds` release, where the Enroute build picks them up.


## Cloning this repository

This repository contains maplibre and the compression libraries as submodules, and maplibre itself
contains submodules. After cloning this repository, the following git command can be used to
download all sub- and sub-sub-modules.

```
git submodule update --init --recursive
```


## Using the build scripts

All scripts are run from the top level of the repository and take no arguments. They expect the
environment variable `Qt6_DIR_BASE` to be set:

| Variable          | Content
|-------------------|---------------------------------
| Qt6_DIR_BASE      | path to the Qt installation tree, as downloaded with the Qt Online installer.

`Qt6_DIR_BASE` must point to the *version* directory of the Qt installation, that is, the directory
that contains the individual kits. The scripts expect to find the Qt development files in the
typical layout provided by the Qt installer.

|Platform           | Path
|-------------------|---------------------------------
|Android/armv7      | $Qt6_DIR_BASE/android_armv7
|Android/arm64_v8a  | $Qt6_DIR_BASE/android_arm64_v8a
|Android/x86        | $Qt6_DIR_BASE/android_x86
|Android/x86_64     | $Qt6_DIR_BASE/android_x86_64
|iOS                | $Qt6_DIR_BASE/ios
|Linux              | $Qt6_DIR_BASE/gcc_64
|macOS              | $Qt6_DIR_BASE/macos

The compiled libraries are **not** installed into the Qt tree. They are installed into a directory
`Qt/<qt-version>/<kit>` inside this repository, mirroring the layout of the Qt installation, so that
the directory can be copied over a Qt installation or packaged as an archive. Intermediate build
directories are named `build-<library>-<platform>`. Both are excluded from git.


### buildscript-android.sh

This build script runs on a Linux or macOS host. It compiles libzip and maplibre-native-qt for all
four Android ABIs.


#### Prerequisites

Beside `Qt6_DIR_BASE`, the script expects that the following environment variables are set.

| Variable          | Content
|-------------------|---------------------------------
| ANDROID_SDK_ROOT  | path to the Android software development kit
| ANDROID_NDK_ROOT  | path to an Android native development kit, compatible with the relevant version of Qt


#### Typical invocation

On the author's machine, the following will work.

```
export ANDROID_SDK_ROOT=$HOME/Software/buildsystems/AndroidSDK
export ANDROID_NDK_ROOT=$ANDROID_SDK_ROOT/ndk/26.1.10909125
export Qt6_DIR_BASE=$HOME/Software/buildsystems/Qt/6.10.1
./buildscript-android.sh
```


### buildscript-ios.sh

This build script runs on a macOS host. It compiles static libraries for zlib and libzip, and then
maplibre-native-qt.

Every library is built twice and the two static archives are then merged with `lipo`: `arm64`
against the `iphoneos` SDK, and `x86_64` against the `iphonesimulator` SDK. This mirrors what Qt
itself ships, where each module is a fat archive with an `arm64` device slice and an `x86_64`
simulator slice. There is no `arm64` simulator slice, because a fat archive cannot hold two `arm64`
slices — that is what XCFrameworks exist for — so the simulator runs `x86_64`, under Rosetta on
Apple Silicon hosts. One install prefix therefore serves both the *Qt for iOS* and the *Qt for iOS
Simulator* kit.

Passing `-DCMAKE_OSX_ARCHITECTURES="arm64;x86_64"` to a single build does *not* work: it compiles
both slices against the *same* SDK, and recent versions of `ld` refuse to link the resulting
`x86_64-ios` objects. Every CMake check that links a test executable then fails, and the build stops
when Qt looks for OpenGL ES.

The device pass owns the install prefix, since headers, CMake package files and pkg-config files are
architecture independent. The simulator pass installs into the scratch prefix
`build-iOS-simulator-stage/` and contributes only its static archives.

libzip is built against the zlib built one step earlier. The script passes
`QT_ADDITIONAL_PACKAGES_PREFIX_PATH` to point Qt's toolchain at the install prefix in this
repository; unlike `CMAKE_PREFIX_PATH`, that variable also extends `CMAKE_FIND_ROOT_PATH`, which a
cross-build needs. Nothing is written into the Qt installation tree.


#### Typical invocation

On the author's machine, the following will work.

```
export Qt6_DIR_BASE=$HOME/Software/buildsystems/Qt/6.10.1
./buildscript-ios.sh
```


### buildscript-linux.sh

This build script runs on a Linux host. It compiles maplibre-native-qt for the desktop.


#### Typical invocation

On the author's machine, the following will work.

```
export Qt6_DIR_BASE=$HOME/Software/buildsystems/Qt/6.10.1
./buildscript-linux.sh
```


### buildscript-macos.sh

This build script runs on a macOS host. It compiles libzip and maplibre-native-qt as universal
binaries for arm64 and x86_64.

If `Qt6_DIR_BASE` is not set, the script looks for the most recent Qt installation below `~/Qt` and
uses that.


#### Typical invocation

On the author's machine, the following will work.

```
export Qt6_DIR_BASE=$HOME/Software/buildsystems/Qt/6.10.1
./buildscript-macos.sh
```


### Further scripts

The repository contains two further scripts that are not part of the regular build.

* `buildscript-android-nt.sh` compiles Qt itself from source for all Android ABIs before building
  the libraries. Paths to the Qt sources and to the host Qt are hard-coded in the script and need to
  be adjusted before use.
* `generateArchive.sh` packs the maplibre-native-qt sources into `maplibre-native-qt.tar.xz`. The
  workflow `.github/workflows/sources.yml` does the same on every push.

The file `buildscript-windows.bat` is currently unmaintained, as is the associated workflow
`.github/workflows/windows.yml`.


## Patching maplibre-native-qt

The repository contains maplibre-native-qt twice.

* `maplibre-native-qt` is the upstream git submodule, with its own submodules. It is used to
  generate the source archive.
* `maplibre-native-qt-flat` is a copy of the same tree, with all submodules resolved into ordinary
  files, checked into this repository. It carries the local patches that are needed to compile with
  current versions of Qt.

The build scripts compile `maplibre-native-qt-flat`. Local fixes therefore go into that directory
and are committed as ordinary changes. Updating to a new upstream release means replacing the
contents of `maplibre-native-qt-flat` and re-applying the local patches. The command

```
diff -rq --exclude=.git maplibre-native-qt maplibre-native-qt-flat
```

shows the differences between the two trees.


## Known quirks

* Building zlib renames the file `zlib/zconf.h` to `zlib/zconf.h.included`, because CMake generates
  that header in the build directory. As a result, the `zlib` submodule appears modified after every
  iOS build. This is a side effect of the build and should not be committed.
