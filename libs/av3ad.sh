#!/usr/bin/env bash
set -e

PREFIX="[av3ad]"

SRC="$SOURCE_DIR/av3ad"
OUT="$DIST_DIR/av3ad"
ABIS="arm64-v8a armeabi-v7a x86 x86_64"

map_project_abi() {
  case "$1" in
    arm64-v8a)
      echo "arm64"
      ;;
    armeabi-v7a)
      echo "armv7a"
      ;;
    x86)
      echo "x86"
      ;;
    x86_64)
      echo "x86_64"
      ;;
    *)
      echo "$1"
      ;;
  esac
}

echo "$PREFIX Clone/update av3ad..."
if [ -d "$SRC/.git" ]; then
  git -C "$SRC" fetch --depth=1 origin "$AV3AD_GIT_BRANCH"
  git -C "$SRC" reset --hard FETCH_HEAD
else
  rm -rf "$SRC"
  git clone --depth 1 -b "$AV3AD_GIT_BRANCH" "$AV3AD_GIT_URL" "$SRC"
fi

echo "$PREFIX Build..."
mkdir -p "$OUT"

for ABI in $ABIS; do
  PROJECT_ABI="$(map_project_abi "$ABI")"
  BUILD_DIR="$SRC/build/$ABI"
  INSTALL_DIR="$OUT/$ABI"

  echo "  -> ABI: $ABI"
  rm -rf "$BUILD_DIR"
  mkdir -p "$BUILD_DIR" "$INSTALL_DIR"

  cmake -S "$SRC" -B "$BUILD_DIR" \
    -DCMAKE_TOOLCHAIN_FILE="$ANDROID_NDK_PATH/build/cmake/android.toolchain.cmake" \
    -DANDROID_ABI="$ABI" \
    -DANDROID_PLATFORM=android-"$ANDROID_API" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="$INSTALL_DIR"

  cmake --build "$BUILD_DIR"
  cmake --install "$BUILD_DIR"

  cp "$BUILD_DIR/libav3ad.a" "$INSTALL_DIR/libav3ad.a"
  mkdir -p "$SOURCE_DIR/media/libraries/decoder_ffmpeg/src/main/jni/ffmpeg/android-libs/$ABI"
  cp "$INSTALL_DIR/libav3ad.a" "$SOURCE_DIR/media/libraries/decoder_ffmpeg/src/main/jni/ffmpeg/android-libs/$ABI/libav3ad.a"
done

echo "$PREFIX Collect artifacts..."
echo "$PREFIX Done:"
echo "  Artifacts -> $OUT/{arm64-v8a,armeabi-v7a,x86,x86_64}"
