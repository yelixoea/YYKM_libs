#!/usr/bin/env bash

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="$ROOT_DIR/build"
DIST_DIR="$ROOT_DIR/dist"

ANDROID_COMMANDLINE_TOOLS_URL="${ANDROID_COMMANDLINE_TOOLS_URL:-https://dl.google.com/android/repository/commandlinetools-linux-14742923_latest.zip}"
ANDROID_NDK_VERSION="${ANDROID_NDK_VERSION:-27.3.13750724}"
ANDROID_CMAKE_VERSION="${ANDROID_CMAKE_VERSION:-3.22.1}"

ANDROID_SDK_ROOT="${ANDROID_SDK_ROOT:-$SOURCE_DIR/android-sdk}"
ANDROID_API="${ANDROID_API:-21}"
ANDROID_HOST_PLATFORM="${ANDROID_HOST_PLATFORM:-linux-x86_64}"
ANDROID_NDK_PATH="$ANDROID_SDK_ROOT/ndk/$ANDROID_NDK_VERSION"
ANDROID_TOOLCHAIN_BIN="$ANDROID_NDK_PATH/toolchains/llvm/prebuilt/$ANDROID_HOST_PLATFORM/bin"

MMKV_GIT_URL="${MMKV_GIT_URL:-https://github.com/yelixoea/MMKV.git}"
MMKV_GIT_BRANCH="${MMKV_GIT_BRANCH:-release/yykm}"

MEDIA_GIT_URL="${MEDIA_GIT_URL:-https://github.com/yelixoea/media.git}"
MEDIA_GIT_BRANCH="${MEDIA_GIT_BRANCH:-release_yykm}"

FFMPEG_GIT_URL="${FFMPEG_GIT_URL:-https://github.com/yelixoea/FFmpeg.git}"
FFMPEG_GIT_BRANCH="${FFMPEG_GIT_BRANCH:-release/yykm/6.1}"
FFMPEG_ENABLED_DECODERS="${FFMPEG_ENABLED_DECODERS:-opus flac alac mp3 aac ac3 eac3 vorbis dca mlp truehd libav3a}"

AV3AD_GIT_URL="${AV3AD_GIT_URL:-https://github.com/yelixoea/av3ad.git}"
AV3AD_GIT_BRANCH="${AV3AD_GIT_BRANCH:-master}"
AV3AD_ANDROID_PLATFORM="${AV3AD_ANDROID_PLATFORM:-android-21}"

TERMUX_EXEC_GIT_URL="${TERMUX_EXEC_GIT_URL:-https://github.com/yelixoea/termux-exec.git}"
TERMUX_EXEC_GIT_BRANCH="${TERMUX_EXEC_GIT_BRANCH:-main}"
TERMUX_EXEC_ANDROID_ABIS="${TERMUX_EXEC_ANDROID_ABIS:-arm64-v8a armeabi-v7a x86 x86_64}"
