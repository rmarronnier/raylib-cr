#!/usr/bin/env sh

set -eu

ROOT="$(CDPATH= cd -- "$(dirname "$0")/../../.." && pwd)"
LIB_DIR="${RAYLIB_CR_LIB_DIR:-$ROOT/libs}"
BUILD_DIR="${RAYLIB_CR_BUILD_DIR:-$ROOT/.native/raygui-build}"
RAYGUI_VERSION="${RAYGUI_VERSION:-4.0}"

if [ -n "${RAYLIB_PREFIX:-}" ]; then
  RAYLIB_INCLUDE="$RAYLIB_PREFIX/include"
  RAYLIB_LIB="$RAYLIB_PREFIX/lib"
elif command -v pkg-config >/dev/null 2>&1 && pkg-config --exists raylib; then
  RAYLIB_PREFIX="$(pkg-config --variable=prefix raylib)"
  RAYLIB_INCLUDE="$RAYLIB_PREFIX/include"
  RAYLIB_LIB="$RAYLIB_PREFIX/lib"
else
  echo "Could not determine raylib installation prefix. Set RAYLIB_PREFIX or install raylib first." >&2
  exit 1
fi

rm -rf "$BUILD_DIR"
mkdir -p "$LIB_DIR" "$BUILD_DIR"

git clone --depth 1 --branch "$RAYGUI_VERSION" https://github.com/raysan5/raygui "$BUILD_DIR/raygui"
cp "$BUILD_DIR/raygui/src/raygui.h" "$BUILD_DIR/raygui/src/raygui.c"

case "$(uname -s)" in
  Darwin)
    cc -dynamiclib -fPIC \
      -I"$RAYLIB_INCLUDE" \
      -DRAYGUI_IMPLEMENTATION \
      "$BUILD_DIR/raygui/src/raygui.c" \
      -L"$RAYLIB_LIB" -lraylib \
      -o "$LIB_DIR/libraygui.dylib"
    ;;
  Linux)
    cc -shared -fPIC \
      -I"$RAYLIB_INCLUDE" \
      -DRAYGUI_IMPLEMENTATION \
      "$BUILD_DIR/raygui/src/raygui.c" \
      -L"$RAYLIB_LIB" -lraylib -lm -lpthread -ldl -lrt -lX11 \
      -o "$LIB_DIR/libraygui.so"
    ;;
  *)
    echo "Unsupported unix platform: $(uname -s)" >&2
    exit 1
    ;;
esac

rm -rf "$BUILD_DIR"
