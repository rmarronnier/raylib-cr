# Manual Validation

Use this checklist before changing platform support claims, after major Raylib upgrades, or after touching native setup scripts.

## macOS

### Core

- `crystal spec --error-trace`
- `crystal run rsrc/smoke/modules.cr`
- `crystal run rsrc/smoke/core.cr`

### Interactive

- build and run at least one basic example from `examples/_build`
- confirm a window opens and closes cleanly
- confirm mouse coordinates behave sensibly in a simple example such as `collisionarea`
- confirm fullscreen behavior in a real downstream project or example if support claims mention it

### Audio

- run `examples/sound_test`
- confirm the audio device initializes and the sound loads

## Ubuntu Linux

### Core

- `crystal spec --error-trace`
- `xvfb-run -a crystal run rsrc/smoke/core.cr`
- `crystal run rsrc/smoke/modules.cr`

### Interactive

- run one example in a real desktop session, not only under `xvfb`
- confirm input and window lifecycle

### Audio

- run `examples/sound_test` on a real machine or desktop VM

## Windows MSVC

### Core

- `crystal spec --error-trace`
- `crystal run rsrc/smoke/core.cr`
- `crystal run rsrc/smoke/modules.cr`

### Interactive

- run one built example from `examples/_build`
- confirm window lifecycle and mouse input

### Audio

- run `examples/sound_test`

## When to rerun the full checklist

- after changing Raylib version assumptions
- after changing install scripts or linker behavior
- after changing `audio.cr` or `ma_sizes.cr`
- after changing CI support claims in the README
