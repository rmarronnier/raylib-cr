#!/usr/bin/env sh

set -eu

ROOT="$(CDPATH= cd -- "$(dirname "$0")/../../.." && pwd)"
PREFIX="${RAYLIB_CR_NATIVE_PREFIX:-$ROOT/.native/ubuntu}"
LIB_DIR="${RAYLIB_CR_LIB_DIR:-$ROOT/libs}"
BUILD_DIR="$ROOT/.native/ubuntu-build"

sudo apt-get update
sudo apt-get install -y \
  build-essential \
  cmake \
  git \
  pkg-config \
  libasound2-dev \
  libx11-dev \
  libxrandr-dev \
  libxi-dev \
  libgl1-mesa-dev \
  libglu1-mesa-dev \
  libxcursor-dev \
  libxinerama-dev \
  xvfb

rm -rf "$PREFIX" "$BUILD_DIR"
mkdir -p "$PREFIX" "$LIB_DIR" "$BUILD_DIR"

git clone --depth 1 --branch 5.5 https://github.com/raysan5/raylib "$BUILD_DIR/raylib"
cmake -S "$BUILD_DIR/raylib" -B "$BUILD_DIR/raylib/build" \
  -DBUILD_SHARED_LIBS=ON \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX="$PREFIX"
cmake --build "$BUILD_DIR/raylib/build" --parallel
cmake --install "$BUILD_DIR/raylib/build"

cp "$PREFIX/lib/libraylib.so" "$LIB_DIR/libraylib.so"
RAYLIB_PREFIX="$PREFIX" RAYLIB_CR_LIB_DIR="$LIB_DIR" sh "$ROOT/rsrc/native/shared/build-raygui-unix.sh"

rm -rf "$BUILD_DIR"

cat <<EOF
Native libraries installed locally.

Export these before building or running programs that need repo-local native libs:
  export LIBRARY_PATH="$LIB_DIR:\${LIBRARY_PATH:-}"
  export LD_LIBRARY_PATH="$LIB_DIR:\${LD_LIBRARY_PATH:-}"
EOF
