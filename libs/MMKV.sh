#!/usr/bin/env bash
set -e

PREFIX="[MMKV]"

SRC="${SOURCE_DIR}/MMKV"
OUT="${DIST_DIR}/MMKV"
ANDROID_PROJ="$SRC/Android/MMKV"

echo "$PREFIX Clone/update MMKV..."
if [ -d "$SRC/.git" ]; then
  git -C "$SRC" fetch --depth=1 origin "$MMKV_GIT_BRANCH"
  git -C "$SRC" reset --hard FETCH_HEAD
else
  rm -rf "$SRC"
  git clone --depth 1 -b "$MMKV_GIT_BRANCH" "$MMKV_GIT_URL" "$SRC"
fi

echo "$PREFIX Build AAR..."
cd "$ANDROID_PROJ"
printf "sdk.dir=%s\n" "$ANDROID_SDK_ROOT" > local.properties
chmod +x gradlew
./gradlew --no-daemon :mmkv:assembleStaticCppRelease

echo "$PREFIX Collect AAR..."
rm -rf "$OUT"
mkdir -p "$OUT"

AAR=$(find "$ANDROID_PROJ/mmkv/build/outputs/aar" -name "*.aar" | sort | tail -n1)
cp -f "$AAR" "$OUT/"

echo "$PREFIX Done:"
echo "  AAR -> $OUT/$(basename "$AAR")"
