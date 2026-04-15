#!/usr/bin/env bash
set -e

PREFIX="[talloc]"

SRC="$SOURCE_DIR/talloc"
OUT="$DIST_DIR/talloc"
ABIS="arm64-v8a armeabi-v7a x86 x86_64"

target_for_abi() {
  case "$1" in
    arm64-v8a)
      echo "aarch64-linux-android"
      ;;
    armeabi-v7a)
      echo "armv7a-linux-androideabi"
      ;;
    x86)
      echo "i686-linux-android"
      ;;
    x86_64)
      echo "x86_64-linux-android"
      ;;
    *)
      echo ""
      ;;
  esac
}

if [ ! -d "$SRC" ]; then
  echo "$PREFIX Download talloc..."
  mkdir -p "$SRC"
  TALLOC_ARCHIVE="$SRC/talloc.tar.gz"
  curl -L -o "$TALLOC_ARCHIVE" "$TALLOC_GZ_URL"
  tar -xzf "$TALLOC_ARCHIVE" -C "$SRC" --strip-components=1
fi

echo "$PREFIX Build..."

cd "$SRC"
rm -rf "$OUT"
mkdir -p "$OUT"

cat <<EOF >cross-answers.txt
Checking uname sysname type: "Linux"
Checking uname machine type: "dontcare"
Checking uname release type: "dontcare"
Checking uname version type: "dontcare"
Checking simple C program: OK
rpath library support: OK
-Wl,--version-script support: FAIL
Checking getconf LFS_CFLAGS: OK
Checking for large file support without additional flags: OK
Checking for -D_FILE_OFFSET_BITS=64: $FILE_OFFSET_BITS
Checking for -D_LARGE_FILES: OK
Checking correct behavior of strtoll: OK
Checking for working strptime: OK
Checking for C99 vsnprintf: OK
Checking for HAVE_SHARED_MMAP: OK
Checking for HAVE_MREMAP: OK
Checking for HAVE_INCOHERENT_MMAP: OK
Checking for HAVE_SECURE_MKSTEMP: OK
Checking getconf large file support flags work: OK
Checking for HAVE_IFACE_IFCONF: FAIL
EOF

sed -i '/replace-test/,/)/ s/^/#/' lib/replace/wscript
sed -i '/replace_testsuite/,/)/ s/^/#/' lib/replace/wscript

for ABI in $ABIS; do
  TARGET="$(target_for_abi "$ABI")"
  if [ -z "$TARGET" ]; then
    echo "$PREFIX Unsupported ABI: $ABI"
    exit 1
  fi

  export CC="$ANDROID_TOOLCHAIN_BIN/${TARGET}${ANDROID_API}-clang"
  export CXX="$ANDROID_TOOLCHAIN_BIN/${TARGET}${ANDROID_API}-clang++"
  export LD="$ANDROID_TOOLCHAIN_BIN/ld"
  export AR="$ANDROID_TOOLCHAIN_BIN/llvm-ar"
  export STRIP="$ANDROID_TOOLCHAIN_BIN/llvm-strip"

  echo "  -> ABI: $ABI"

  make distclean >/dev/null 2>&1 || true
  rm -rf install

  ./configure build \
    --prefix="$PWD/install" \
    --host="$TARGET" \
    --disable-rpath \
    --disable-python \
    --cross-compile \
    --cross-answers=cross-answers.txt

  make -j

  mkdir -p "$OUT/$ABI/include" "$OUT/$ABI/lib"
  "$AR" rcs "$OUT/$ABI/lib/libtalloc.a" bin/default/*.o bin/default/lib/replace/*.o
  cp -f talloc.h "$OUT/$ABI/include"
done

echo "$PREFIX Done:"
echo "  Include -> $OUT/{arm64-v8a,armeabi-v7a,x86,x86_64}/include"
echo "  Lib -> $OUT/{arm64-v8a,armeabi-v7a,x86,x86_64}/lib"
