#!/usr/bin/env bash
set -e

source vars.sh

mkdir -p $SOURCE_DIR $DIST_DIR

source "$ROOT_DIR/dep.sh"
source "$ROOT_DIR/android.sh"

LIB="$1"

case "$LIB" in
  MMKV)
    source "$ROOT_DIR/libs/MMKV.sh"
    ;;
  media)
    source "$ROOT_DIR/libs/av3ad.sh"
    source "$ROOT_DIR/libs/media.sh"
    ;;
  av3ad)
    source "$ROOT_DIR/libs/av3ad.sh"
    ;;
  termux-exec)
    source "$ROOT_DIR/libs/termux-exec.sh"
    ;;
  proot)
    source "$ROOT_DIR/libs/talloc.sh"
    source "$ROOT_DIR/libs/proot.sh"
    ;;
  *)
    echo "Unknown library: $LIB"
    exit 1
    ;;
esac
