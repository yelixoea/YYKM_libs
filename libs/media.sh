#!/usr/bin/env bash
set -e

PREFIX="[media]"

SRC="$SOURCE_DIR/media"
OUT="$DIST_DIR/media"
MODULE_DIR="$SRC/libraries/decoder_ffmpeg"
FFMPEG_MODULE_PATH="$MODULE_DIR/src/main"
FFMPEG_DIR="$FFMPEG_MODULE_PATH/jni/ffmpeg"
JNI_DIR="$FFMPEG_MODULE_PATH/jni"

echo "$PREFIX Clone/update media..."
if [ -d "$SRC/.git" ]; then
  git -C "$SRC" fetch --depth=1 origin "$MEDIA_GIT_BRANCH"
  git -C "$SRC" reset --hard FETCH_HEAD
else
  rm -rf "$SRC"
  git clone --depth 1 -b "$MEDIA_GIT_BRANCH" "$MEDIA_GIT_URL" "$SRC"
fi

echo "$PREFIX Clone/update FFmpeg..."
if [ -d "$FFMPEG_DIR/.git" ]; then
  git -C "$FFMPEG_DIR" fetch --depth=1 origin "$FFMPEG_GIT_BRANCH"
  git -C "$FFMPEG_DIR" reset --hard FETCH_HEAD
else
  rm -rf "$FFMPEG_DIR"
  git clone --depth 1 -b "$FFMPEG_GIT_BRANCH" "$FFMPEG_GIT_URL" "$FFMPEG_DIR"
fi

echo "$PREFIX Build FFmpeg..."
cd "$JNI_DIR"
chmod +x build_ffmpeg.sh

DECODERS=($FFMPEG_ENABLED_DECODERS)

./build_ffmpeg.sh \
  "$FFMPEG_MODULE_PATH" \
  "$ANDROID_NDK_PATH" \
  "$ANDROID_HOST_PLATFORM" \
  "$ANDROID_API" \
  "$DIST_DIR/av3ad" \
  "${DECODERS[@]}"

echo "$PREFIX Build AAR..."
printf "sdk.dir=%s\n" "$ANDROID_SDK_ROOT" > "$SRC/local.properties"

cd "$SRC"
chmod +x gradlew
./gradlew --no-daemon :lib-decoder-ffmpeg:assembleRelease

echo "$PREFIX Collect AAR..."
rm -rf "$OUT"
mkdir -p "$OUT"

AAR=$(find "$MODULE_DIR/buildout/outputs/aar" -name "*release*.aar" | sort | tail -n1)
cp -f "$AAR" "$OUT/"

echo "$PREFIX Done:"
echo "  AAR -> $OUT/$(basename "$AAR")"
