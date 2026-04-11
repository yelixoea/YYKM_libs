#!/usr/bin/env bash
set -e

PREFIX="[dep]"

SUDO=${EUID:+sudo}
[ "$EUID" -eq 0 ] && SUDO=""

echo -e "$PREFIX Install dependencies..."
$SUDO apt-get install -y git openjdk-17-jdk curl unzip make
echo -e "$PREFIX Done"
