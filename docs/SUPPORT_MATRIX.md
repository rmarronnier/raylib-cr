# Support Matrix

## Support tiers

### Supported

- macOS
- Ubuntu Linux
- Windows MSVC

### Best effort

- Windows MSYS2

### Experimental

- other platforms not explicitly listed above

## Validation matrix

| Platform | Core shard specs | Core smoke | Optional modules smoke | Example builds | Native setup path |
| --- | --- | --- | --- | --- | --- |
| macOS | Yes | Compile smoke in CI, runtime manual | Yes | Yes | Homebrew `raylib` + local `raygui` helper |
| Ubuntu Linux | Yes | Runtime smoke in CI | Yes | Yes | repo-local build helper |
| Windows MSVC | Yes | Compile smoke in CI, runtime manual | Yes | Yes | repo-local build helper |
| Windows MSYS2 | Local only | Local only | Local only | Local only | best-effort script |

## What each validation tier means

- `Core shard specs`
  Crystal specs that validate the shard itself.
- `Core smoke`
  Hidden-window smoke for the core Raylib binding. On hosted macOS and Windows runners this is compile-only; runtime window validation remains manual.
- `Optional modules smoke`
  Smoke coverage for `raygui`, `rlgl`, `audio`, and `lights`.
- `Example builds`
  The bundled example programs compile successfully.

## Current caveats

- `raygui` needs its own native library and is not provided by Raylib itself.
- audio is validated at compile level in CI and should still be manually checked on real machines when platform behavior changes.
- fullscreen and other highly interactive runtime paths should be confirmed with the manual checklist before changing support claims.

## Promotion policy

A platform should not be called `Supported` unless it has:

- CI coverage
- a documented primary setup path
- passing shard specs
- passing smoke coverage
- passing example builds

If one of those drops out, the support tier should be revised in the README.
