# Audio Binding Notes

`raylib-cr/audio` uses compile-time miniaudio size detection from:

- [audio.cr](../src/raylib-cr/audio.cr)
- [ma_sizes.cr](../src/raylib-cr/miniaudio_fix/ma_sizes.cr)

## Why this exists

Raylib embeds some miniaudio structs by value, while Crystal FFI needs struct sizes at compile time.

The shard solves this by compiling and running a tiny C helper at Crystal compile time to detect the correct struct sizes for the current platform and toolchain.

## Implications

- this is one of the most platform-sensitive parts of the shard
- audio regressions can appear on one OS even when the rest of the binding still compiles
- CI should always compile the audio module on supported platforms

## Failure modes

If audio compilation fails:

1. confirm the C toolchain is available
2. inspect `src/raylib-cr/miniaudio_fix/ma_sizes.cr`
3. verify the helper C file at `rsrc/miniaudiohelpers/miniaudio-size-check.c` still compiles on the platform
4. re-check any recent platform-specific changes to Crystal, compilers, or Raylib

## Validation expectation

- CI must compile the audio module on all supported platforms
- real audio playback should still be manually verified before changing support claims
