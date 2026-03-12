#!/usr/bin/env sh

set -eu

ROOT="$(CDPATH= cd -- "$(dirname "$0")/../../.." && pwd)"
LIB_DIR="${RAYLIB_CR_LIB_DIR:-$ROOT/libs}"
BUILD_DIR="$ROOT/.native/msys2-build"

pacman -Sy --needed --noconfirm \
  "${MINGW_PACKAGE_PREFIX:+${MINGW_PACKAGE_PREFIX}-}gcc" \
  "${MINGW_PACKAGE_PREFIX:+${MINGW_PACKAGE_PREFIX}-}pkg-config" \
  "${MINGW_PACKAGE_PREFIX:+${MINGW_PACKAGE_PREFIX}-}raylib" \
  git

rm -rf "$BUILD_DIR"
mkdir -p "$LIB_DIR" "$BUILD_DIR"

git clone --depth 1 --branch 4.0 https://github.com/raysan5/raygui "$BUILD_DIR/raygui"
cp "$BUILD_DIR/raygui/src/raygui.h" "$BUILD_DIR/raygui/src/raygui.c"
cc -shared -DRAYGUI_IMPLEMENTATION -I"${MINGW_PREFIX}/include" \
  "$BUILD_DIR/raygui/src/raygui.c" \
  -L"${MINGW_PREFIX}/lib" -lraylib -lm -lpthread \
  -o "$LIB_DIR/raygui.dll" \
  -Wl,--out-implib,"$LIB_DIR/libraygui.dll.a"

cp "${MINGW_PREFIX}/bin/libraylib.dll" "$LIB_DIR/" 2>/dev/null || true
rm -rf "$BUILD_DIR"

cat <<EOF
MSYS2 best-effort setup complete.

For local builds and runs:
  export LIBRARY_PATH="$LIB_DIR:\${LIBRARY_PATH:-}"
  export PATH="$LIB_DIR:\${PATH:-}"
EOF
