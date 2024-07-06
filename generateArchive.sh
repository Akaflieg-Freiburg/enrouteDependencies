#!/bin/bash

git pull
git submodule update --recursive
git clean -fd

cd maplibre-native-qt
rm -f ../maplibre-native-qt.tar.xz
tar cvJf ../maplibre-native-qt.tar.xz --exclude='.git' .
