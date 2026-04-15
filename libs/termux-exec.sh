#!/usr/bin/env bash
set -e

PREFIX="[termux-exec]"

SRC="$SOURCE_DIR/termux-exec"
OUT="$DIST_DIR/termux-exec"
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

echo "$PREFIX Clone/update termux-exec..."
if [ -d "$SRC/.git" ]; then
	git -C "$SRC" fetch --depth=1 origin "$TERMUX_EXEC_GIT_BRANCH"
	git -C "$SRC" reset --hard FETCH_HEAD
else
	rm -rf "$SRC"
	git clone --depth 1 -b "$TERMUX_EXEC_GIT_BRANCH" "$TERMUX_EXEC_GIT_URL" "$SRC"
fi

echo "$PREFIX Build .so..."
rm -rf "$OUT"
mkdir -p "$OUT"

for ABI in $ABIS; do
	CC_NAME="$(compiler_for_abi "$ABI")"
	CC="$ANDROID_TOOLCHAIN_BIN/$CC_NAME"

	DEST="$OUT/$ABI"
	mkdir -p "$DEST"

	echo "  -> ABI: $ABI"
	make -C "$SRC" clean >/dev/null 2>&1 || true
	make -C "$SRC" libtermux-exec.so CC="$CC"

	cp -f "$SRC/libtermux-exec.so" "$DEST/"
done

echo "$PREFIX Done:"
echo "  SO -> $OUT/{arm64-v8a,armeabi-v7a,x86,x86_64}/libtermux-exec.so"
tar -czf "$DIST_DIR/termux-exec.tar.gz" -C "$DIST_DIR" termux-exec
