#!/usr/bin/env bash
set -e

PREFIX="[android]"

TMP="$ANDROID_SDK_ROOT/.tmp"
SDK="$ANDROID_SDK_ROOT/cmdline-tools/latest"
ZIP="$TMP/tools.zip"
SDKMANAGER="$SDK/bin/sdkmanager"
PLATFORM_TOOLS_DIR="$ANDROID_SDK_ROOT/platform-tools"
CMAKE_DIR="$ANDROID_SDK_ROOT/cmake/$ANDROID_CMAKE_VERSION"
NDK_DIR="$ANDROID_SDK_ROOT/ndk/$ANDROID_NDK_VERSION"

mkdir -p "$SDK" "$TMP"

if [ ! -x "$SDKMANAGER" ]; then
  echo "$PREFIX Download tools..."
  curl "$ANDROID_COMMANDLINE_TOOLS_URL" -o "$ZIP"
  unzip -q -o "$ZIP" -d "$TMP"
  rm -f "$ZIP"
  mv "$TMP/cmdline-tools/." "$SDK"
  yes | "$SDKMANAGER" --sdk_root="$ANDROID_SDK_ROOT" --licenses >/dev/null || true
else
  echo "$PREFIX SDK manager exists: $SDKMANAGER"
fi

if [ ! -d "$PLATFORM_TOOLS_DIR" ]; then
  echo "$PREFIX Install platform-tools..."
  "$SDKMANAGER" --sdk_root="$ANDROID_SDK_ROOT" "platform-tools"
else
  echo "$PREFIX platform-tools exists: $PLATFORM_TOOLS_DIR"
fi

if [ ! -d "$CMAKE_DIR" ]; then
  echo "$PREFIX Install CMake..."
  "$SDKMANAGER" --sdk_root="$ANDROID_SDK_ROOT" "cmake;${ANDROID_CMAKE_VERSION}"
else
  echo "$PREFIX CMake exists: $CMAKE_DIR"
fi

if [ ! -d "$NDK_DIR" ]; then
  echo "$PREFIX Install NDK..."
  "$SDKMANAGER" --sdk_root="$ANDROID_SDK_ROOT" "ndk;${ANDROID_NDK_VERSION}"
else
  echo "$PREFIX NDK exists: $NDK_DIR"
fi

echo "$PREFIX Done"
