# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repository is

A build harness — not an application. It compiles third-party libraries (maplibre-native-qt,
libzip, zlib, bzip2) against a Qt 6 installation for every platform that
[Enroute Flight Navigation](https://github.com/Akaflieg-Freiburg/enroute) targets, and ships the
resulting binaries as tarballs. There is no first-party source code here; everything that is not a
build script is vendored upstream code.

## Setup

```
git submodule update --init --recursive     # maplibre-native-qt pulls ~15 nested submodules
export Qt6_DIR_BASE=/path/to/Qt/6.10.1      # parent of macos/, gcc_64/, ios/, android_*/
```

`Qt6_DIR_BASE` must point at the *version* directory of a Qt Online Installer tree, not at a kit.
Each script then invokes `$Qt6_DIR_BASE/<kit>/bin/qt-cmake`. `buildscript-macos.sh` is the only one
that auto-detects it (newest `~/Qt/*/macos/bin/qt-cmake`).

## Building

One script per host/target; run from the repo root, no arguments:

| Script | Host | Builds |
|---|---|---|
| `buildscript-macos.sh` | macOS | libzip, maplibre — universal `arm64;x86_64` |
| `buildscript-ios.sh` | macOS | zlib, libzip, maplibre — static, arm64 device + x86_64 simulator, lipo'd together |
| `buildscript-linux.sh` | Linux | maplibre only |
| `buildscript-android.sh` | Linux/macOS | libzip + maplibre for all four ABIs |
| `buildscript-android-nt.sh` | Linux | builds **Qt itself** from source into `QtAndroid/`, then the libs. Hard-codes `$HOME/Software/buildsystems/Qt/6.8.2` — edit before use. |
| `buildscript-windows.bat` | — | stale: it is a bash script despite the extension, and targets the retired `maplibre-native-qt/` tree |

All of them install into `Qt/$(basename $Qt6_DIR_BASE)/<kit>/` *inside the repo* (gitignored), which
CI tars up. Build directories are `build-<library>-<platform>/`, also gitignored. Scripts use
`set -e`; there is no incremental/partial mode — to rebuild one library, run its `qt-cmake` +
`cmake --build` + `cmake --install` block by hand.

There are no tests and no linter. Verification means running the platform script to completion, or
pushing and watching the workflow.

## The two maplibre trees — read before touching maplibre

- `maplibre-native-qt/` is the **git submodule** (upstream v3.0.0+, with recursive sub-submodules).
- `maplibre-native-qt-flat/` is a **checked-in flat copy** of that tree (~66k files, submodules
  resolved into plain files) that carries local patches.

The current build scripts (`macos`, `ios`, `linux`, `android`) build **`-flat`**. The submodule is
still consumed by `.github/workflows/sources.yml` (which tars it for the `developerBuilds` release),
by `android.yml` / `windows.yml`, and by the two legacy scripts.

Local patches in `-flat` vs upstream (commit `cb2773ae`, "fix compilation with Qt 6.10.1"):

- `CMakeLists.txt` — adds `LocationPrivate` to the `find_package(Qt6 COMPONENTS Location …)` call
- `src/core/style/source_style_change.cpp` — `(void)geojson.open(...)` to silence nodiscard

So: a maplibre fix goes into `maplibre-native-qt-flat/` (and is committed as ordinary files);
an upstream bump means re-flattening the submodule and re-applying those patches. `diff -rq
--exclude=.git maplibre-native-qt maplibre-native-qt-flat` shows what has drifted — ignore the
"Only in" noise, which is just files the flat copy's `.gitignore` excluded.

## Gotchas

- **zlib dirties itself.** Configuring `zlib` renames `zconf.h` → `zconf.h.included` in the *source*
  tree, so `git status` shows the `zlib` submodule modified with a deleted `zconf.h` after any iOS
  build. That is build fallout, not a change — never commit it.
- **`buildscript-ios.sh` builds everything twice.** Qt for iOS ships fat archives with an `arm64`
  device slice and an `x86_64` simulator slice — there is no `arm64` simulator slice, since a fat
  archive cannot hold two `arm64` slices. So the script runs its whole `buildFor` body once against
  the `iphoneos` SDK (into the install prefix) and once against `iphonesimulator` (into
  `build-iOS-simulator-stage/`), then `lipo`s the archives together. Do not "simplify" that into a
  single `-DCMAKE_OSX_ARCHITECTURES="arm64;x86_64"` build — that compiles both slices against one
  SDK and ld rejects the result. It no longer copies anything into `$Qt6_DIR_BASE`; libzip finds
  zlib through `QT_ADDITIONAL_PACKAGES_PREFIX_PATH`. It does delete `libz*.dylib` from the install
  prefix, because dynamic libs break iOS linking.
- **Consumers must ask for `x86_64` on the simulator.** Qt's toolchain file pins
  `CMAKE_OSX_ARCHITECTURES` to `arm64`, so a project configured with
  `-DCMAKE_OSX_SYSROOT=iphonesimulator` and nothing else links `arm64` device objects and fails.
  Enroute's own `CMakeLists.txt` forces `x86_64` in that case, before `project()`.

## CI

`.github/workflows/{android,ios,linux,macos,sources}.yml` fire on push to `main` (each ignores the
other workflows' paths, so editing one workflow only reruns that one). Every job ends with
`gh release upload --clobber developerBuilds *.tar.gz` — the artifacts live on a single rolling
`developerBuilds` release, which is what the Enroute build consumes.

`ios.yml`, `linux.yml` and `macos.yml` call the buildscripts (passing
`Qt6_DIR_BASE=$(dirname "$Qt6_DIR")`). `android.yml` inlines its own `qt-cmake` invocations against
the submodule instead, so it drifts from `buildscript-android.sh` — change both together.
`windows.yml` is stale (triggers on a `feature/actions` branch, runs `apt install` on a Windows
runner) and is not part of the working set.

Each workflow pins its own Qt version (android 6.8.1, ios 6.9.\*, linux 6.10.3, macos 6.10.1); they
are intentionally not in lockstep.
