#!/usr/bin/env bash
set -e

PREFIX="[proot]"

SRC="$SOURCE_DIR/proot"
OUT="$DIST_DIR/proot"
ABIS="arm64-v8a armeabi-v7a x86 x86_64"

compiler_for_abi() {
  case "$1" in
    arm64-v8a)
      echo "aarch64-linux-android${ANDROID_API}-clang"
      ;;
    armeabi-v7a)
      echo "armv7a-linux-androideabi${ANDROID_API}-clang"
      ;;
    x86)
      echo "i686-linux-android${ANDROID_API}-clang"
      ;;
    x86_64)
      echo "x86_64-linux-android${ANDROID_API}-clang"
      ;;
    *)
      echo ""
      ;;
  esac
}

echo "$PREFIX Clone/update proot..."
if [ -d "$SRC/.git" ]; then
  git -C "$SRC" fetch --depth=1 origin "$PROOT_GIT_BRANCH"
  git -C "$SRC" reset --hard FETCH_HEAD
else
  rm -rf "$SRC"
  git clone --depth 1 -b "$PROOT_GIT_BRANCH" "$PROOT_GIT_URL" "$SRC"
fi

echo "$PREFIX Build..."
rm -rf "$OUT"
mkdir -p "$OUT"

cd "$SRC"
for ABI in $ABIS; do
  echo "  -> ABI: $ABI"

  TALLOC="$DIST_DIR/talloc/$ABI"

  CC_NAME="$(compiler_for_abi "$ABI")"
  CC="$ANDROID_TOOLCHAIN_BIN/$CC_NAME"
  STRIP="$ANDROID_TOOLCHAIN_BIN/llvm-strip"
  OBJDUMP="$ANDROID_TOOLCHAIN_BIN/llvm-objdump"
  OBJCOPY="$ANDROID_TOOLCHAIN_BIN/llvm-objcopy"

  make -C src clean
  make -C src loader.elf \
      CC="$CC" \
      STRIP="$STRIP" \
      OBJDUMP="$OBJDUMP" \
      OBJCOPY="$OBJCOPY" \
      CFLAGS="-I$TALLOC/include" \
      LDFLAGS="-L$TALLOC/lib -ltalloc"
  make -C src proot \
      CC="$CC" \
      STRIP="$STRIP" \
      OBJDUMP="$OBJDUMP" \
      OBJCOPY="$OBJCOPY" \
      CFLAGS="-I$TALLOC/include" \
      LDFLAGS="-L$TALLOC/lib -ltalloc"

  mkdir -p "$OUT/$ABI"
  cp -f src/loader.elf "$OUT/$ABI/libloader.so"
  cp -f src/proot "$OUT/$ABI/libproot.so"
done

echo "$PREFIX Done:"
echo "  Binaries -> $OUT/{arm64-v8a,armeabi-v7a,x86,x86_64}/libloader.so,libproot.so"
tar -czf "$DIST_DIR/proot.tar.gz" -C "$DIST_DIR" proot
