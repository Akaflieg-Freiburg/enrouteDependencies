# enrouteDependencies

This repository hosts build scripts for the dependencies of Enroute Flight Navigation. Currently, this is the maplibre port for Qt, [maplibre-native-qt](https://github.com/maplibre/maplibre-native-qt). On iOS, these are a universal static libraries for libzip and zlib. 


## Cloning this repository

This repository contains maplibre as a submodule, which itself contains submodules. After cloning this repository, the following git command can be used to download all sub- and sub-sub-modules.

```
git submodule update --init --recursive
```


## Using the build scripts


### buildscript-android.sh 

This build script runs on a Linux or macOS host. It compiles maplibre-native-qt and installs the binaries directly into the Qt development tree. 


#### Prerequisites

The script expects that the following environment variables are set.

| Variable          | Content
|-------------------|---------------------------------
| Qt6_DIR_BASE      | path to the Qt installation tree, as downloaded with the Qt Online installer.
| ANDROID_SDK_ROOT  | path to the Android software development kit
| ANDROID_NDK_ROOT  | path to an Android native development kit, compatible with the relevant version of Qt

The script expects to find the Qt development files in the typical layout provided by the Qt installer.

|Platform           | Path
|-------------------|---------------------------------
|Android/armv7      | $Qt6_DIR_BASE/android_armv7
|Android/arm64_v8a  | $Qt6_DIR_BASE/android_arm64_v8a
|Android/x86        | $Qt6_DIR_BASE/android_x86
|Android/x86_64     | $Qt6_DIR_BASE/android_x86_64


#### Typical invocation

On the author's machine, the following will work.

```
export ANDROID_SDK_ROOT=$HOME/Software/buildsystems/AndroidSDK
export ANDROID_NDK_ROOT=$ANDROID_SDK_ROOT/ndk/25.1.8937393
export Qt6_DIR_BASE=/home/kebekus/Software/buildsystems/Qt/6.6.0
./buildscript-maplibre-linux.sh 
```


### buildscript-ios.sh 

This build script runs on a macOS host. It compiles universal static libraries for libzip and zlib, and installs the binaries directly into the Qt development tree. 


#### Prerequisites

The script expects that the following environment variables are set.

| Variable          | Content
|-------------------|---------------------------------
| Qt6_DIR_BASE      | path to the Qt installation tree, as downloaded with the Qt Online installer.


#### Typical invocation

On the author's machine, the following will work.

```
export Qt6_DIR_BASE=/Users/kebekus/Software/buildsystems/Qt/6.4.3
./buildscript-ios.sh 
```


### buildscript-linux.sh 

This build script runs on a Linux host. It compiles maplibre-native-qt for the following platforms and installs the binaries directly into the Qt development tree. 


#### Prerequisites

The script expects that the following environment variables are set.

| Variable          | Content
|-------------------|---------------------------------
| Qt6_DIR_BASE      | path to the Qt installation tree, as downloaded with the Qt Online installer.


#### Typical invocation

On the author's machine, the following will work.

```
export Qt6_DIR_BASE=/home/kebekus/Software/buildsystems/Qt/6.6.0
./buildscript-linux.sh 
```


### buildscript-macos.sh 

This build script runs on a macOS host. It compiles maplibre-native-qt for the following platforms and installs the binaries directly into the Qt development tree. 


#### Prerequisites

The script expects that the following environment variables are set.

| Variable          | Content
|-------------------|---------------------------------
| Qt6_DIR_BASE      | path to the Qt installation tree, as downloaded with the Qt Online installer.


#### Typical invocation

On the author's machine, the following will work.

```
export Qt6_DIR_BASE=/Users/kebekus/Software/buildsystems/Qt/6.6.0
./buildscript-macos.sh 
```
