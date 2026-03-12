![logo](logo/raylib-cr_256x256.png)

[![CI](https://github.com/rmarronnier/raylib-cr/actions/workflows/ci.yml/badge.svg)](https://github.com/rmarronnier/raylib-cr/actions/workflows/ci.yml)
[![Examples](https://github.com/rmarronnier/raylib-cr/actions/workflows/examples.yml/badge.svg)](https://github.com/rmarronnier/raylib-cr/actions/workflows/examples.yml)

# raylib-cr

Crystal bindings for Raylib `5.5`.

The shard intentionally stays close to raw Raylib. `raymath` bindings are included, along with optional `raygui`, `rlgl`, `audio`, and `lights` modules.

## Support

### Supported

- macOS
  CI covers specs, core smoke, optional module smoke, and example builds.
- Ubuntu Linux
  CI covers specs, core smoke, optional module smoke, and example builds.
- Windows MSVC
  CI covers specs, core smoke, optional module smoke, and example builds.

### Best effort

- Windows MSYS2
  Kept as a supported path for local use, but not currently part of the primary CI matrix.

### Experimental

- Other Linux distributions and platforms not covered above

More detail is in [SUPPORT_MATRIX.md](docs/SUPPORT_MATRIX.md) and [MANUAL_VALIDATION.md](docs/MANUAL_VALIDATION.md).

## Native dependency model

`raylib-cr` binds to the native Raylib library, so you still need Raylib installed on the machine.

`raygui` is separate from Raylib and needs its own native library if you use `require "raylib-cr/raygui"`.

The repo-local helper scripts under `rsrc/native/` build any missing native libraries into `./libs` instead of copying them into global system locations.

## Installation

## macOS

Primary path:

```sh
brew install crystal pkg-config raylib
shards install
```

If you need `raygui` or want to build the bundled examples locally:

```sh
sh rsrc/native/mac/mac-raylib-install.sh
export LIBRARY_PATH="$PWD/libs:${LIBRARY_PATH:-}"
export DYLD_FALLBACK_LIBRARY_PATH="$PWD/libs:${DYLD_FALLBACK_LIBRARY_PATH:-}"
```

## Ubuntu Linux

If your distro already packages Raylib `5.5`, you can use that directly.

For a deterministic repo-local setup that builds Raylib and `raygui` into `./libs`:

```sh
sh rsrc/native/ubuntu/install.sh
export LIBRARY_PATH="$PWD/libs:${LIBRARY_PATH:-}"
export LD_LIBRARY_PATH="$PWD/libs:${LD_LIBRARY_PATH:-}"
```

Then:

```sh
shards install
```

## Windows MSVC

Primary path:

1. Install Crystal with Scoop.
2. Open a Visual Studio developer shell or let the CI-style helper set it up.
3. Run:

```powershell
powershell -ExecutionPolicy Bypass -File .\rsrc\native\windows\install.ps1
$env:LIB = "$pwd\libs;$env:LIB"
$env:PATH = "$pwd\libs;$env:PATH"
shards install
```

## Windows MSYS2

Best-effort path:

```sh
sh rsrc/native/msys2/install.sh
export LIBRARY_PATH="$PWD/libs:${LIBRARY_PATH:-}"
export PATH="$PWD/libs:${PATH:-}"
shards install
```

## Usage

```crystal
require "raylib-cr"

Raylib.init_window(800, 450, "Hello World")
Raylib.set_target_fps(60)

until Raylib.close_window?
  Raylib.begin_drawing
  Raylib.clear_background(Raylib::RAYWHITE)
  Raylib.draw_text("Hello World!", 190, 200, 20, Raylib::BLACK)
  Raylib.end_drawing
end

Raylib.close_window
```

## Optional modules

```crystal
require "raylib-cr/raygui"
require "raylib-cr/rlgl"
require "raylib-cr/audio"
require "raylib-cr/lights"
```

`raygui` requires a native `raygui` library. The helper scripts above build it into `./libs`.

## Validation

Local shard validation:

```sh
crystal spec --error-trace
crystal run rsrc/smoke/audio.cr
crystal run rsrc/smoke/modules.cr
crystal run rsrc/smoke/core.cr
```

Build all bundled examples:

```sh
crystal run rsrc/build-examples/build.cr
```

## Contributing

1. Fork the repository.
2. Create a feature branch.
3. Run the local validation commands above.
4. Open a pull request.

When changing platform support, also update:

- [SUPPORT_MATRIX.md](docs/SUPPORT_MATRIX.md)
- [MANUAL_VALIDATION.md](docs/MANUAL_VALIDATION.md)
- any affected scripts under `rsrc/native/`

## Credits

- [sol-vin](https://github.com/sol-vin)
- [rightbrace](https://github.com/b1tlet) for major contributions around `raymath` and wrappers
- [AregevDev](https://github.com/AregevDev) as original creator
