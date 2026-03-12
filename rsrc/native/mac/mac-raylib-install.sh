#!/usr/bin/env sh

set -eu

ROOT="$(CDPATH= cd -- "$(dirname "$0")/../../.." && pwd)"
LIB_DIR="${RAYLIB_CR_LIB_DIR:-$ROOT/libs}"

if command -v brew >/dev/null 2>&1; then
  brew list pkg-config >/dev/null 2>&1 || brew install pkg-config
  brew list raylib >/dev/null 2>&1 || brew install raylib
else
  echo "Homebrew is required for the primary macOS setup path." >&2
  echo "Install Homebrew, then rerun this script." >&2
  exit 1
fi

mkdir -p "$LIB_DIR"
RAYLIB_PREFIX="$(brew --prefix raylib)" RAYLIB_CR_LIB_DIR="$LIB_DIR" sh "$ROOT/rsrc/native/shared/build-raygui-unix.sh"

cat <<EOF
raygui built into $LIB_DIR.

For local builds and runs that need repo-local native libs:
  export LIBRARY_PATH="$LIB_DIR:\${LIBRARY_PATH:-}"
  export DYLD_FALLBACK_LIBRARY_PATH="$LIB_DIR:\${DYLD_FALLBACK_LIBRARY_PATH:-}"
EOF
