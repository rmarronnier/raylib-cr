# Platform Support Hardening Plan

## Goal

Bring `raylib-cr` to a support level where macOS is no longer described as `Weak/Broken support`, while also improving Linux and Windows support so the project has one coherent, validated cross-platform story.

This plan is grounded in the current repository state:

- `README.md` still marks macOS as weak/broken and only advertises Ubuntu/Windows CI.
- `.github/workflows/` contains Ubuntu and Windows workflows only.
- native install scripts under `rsrc/native/` still build or install Raylib `5.0` artifacts by hand.
- macOS install/build scripts copy libraries into `/usr/local/lib` and do not reflect current Homebrew-based setups.
- Windows and Linux install scripts build and copy artifacts manually instead of preferring package-manager discovery.
- the repo has a duplicate legacy `github-workflows/` directory outside `.github/workflows/`.
- audio support still depends on compile-time miniaudio size detection, which is correct but platform-sensitive.

## Principles

1. No platform-specific engine workarounds in downstream consumers just to compensate for shard support gaps.
2. Prefer validated package-manager installs over custom system-wide shell scripts.
3. Keep bindings raw where appropriate, but explicitly validate the subset claimed to be supported.
4. Make CI the source of truth for platform support claims.
5. Separate `builds on CI` from `feature-complete on CI`; both matter, but they are different gates.

## Current Problems

### 1. Support claims are not backed by current validation

- macOS has no CI lane.
- Linux and Windows CI only build examples; they do not prove core smoke behavior.
- README support language is historical, not evidence-based.

### 2. Native install story is outdated

- macOS scripts still clone/build Raylib `5.0`.
- Ubuntu scripts still clone/build Raylib `5.0`.
- Windows scripts also build `5.0`.
- scripts install into global locations like `/usr/local/lib`, `/usr/lib`, `/lib`, or `C:\raylib`.
- these scripts are high-friction, invasive, and hard to reason about in CI and on developer machines.

### 3. CI is too narrow and too old

- workflows use older GitHub Actions versions.
- there is no macOS runner coverage.
- current jobs do not explicitly validate:
  - core `require "raylib-cr"` compile
  - `init_window` / `close_window`
  - fullscreen toggle path
  - input coordinate path
  - audio module compile/init path
  - `raygui`, `rlgl`, `lights`, `audio` extension imports

### 4. Packaging/linking expectations are implicit

- Darwin links Apple frameworks in `src/raylib-cr/raylib.cr`, which is normal, but the shard docs do not clearly explain what the native dependency source should be.
- there is no single authoritative documented path for:
  - Homebrew on macOS
  - apt/system package vs build-from-source on Linux
  - MSVC/MSYS2 on Windows

### 5. Audio remains the riskiest platform area

- `src/raylib-cr/audio.cr` depends on compile-time generated miniaudio dummy struct sizes.
- `src/raylib-cr/miniaudio_fix/ma_sizes.cr` is necessary today, but it is one of the most platform-sensitive parts of the shard.
- this is exactly the kind of path that can quietly regress on one OS while still compiling elsewhere.

### 6. Repository hygiene is hurting support clarity

- duplicate `github-workflows/` directory suggests legacy workflow drift.
- native scripts are inconsistent across OSes.
- README installation guidance is inconsistent with the actual current Raylib/Homebrew/package-manager ecosystem.

## Desired End State

The shard should have:

- explicit support tiers:
  - `Supported`
  - `Best effort`
  - `Experimental`
- CI-backed support for:
  - macOS
  - Ubuntu Linux
  - Windows
- one documented primary install path per OS
- smoke validation for core windowed usage and audio module compilation
- README language that matches real validation
- no stale references to Raylib `5.0`
- no system-wide install scripts as the primary path

## Scope

### In scope

- CI modernization
- macOS support hardening
- Linux and Windows install/documentation cleanup
- smoke and compile validation
- README/support policy rewrite
- pruning stale workflow/install assets where safe

### Out of scope for this pass

- redesigning the entire audio binding architecture
- wrapping every raw Raylib API in higher-level Crystal abstractions
- guaranteeing every interactive runtime behavior in headless CI
- solving every possible native packaging edge case

## Phased Plan

## Phase 0: Baseline and inventory

### Objective

Get a clean, explicit baseline of what currently works on each OS and where support claims are stale.

### Tasks

- Create a support matrix document listing:
  - OS
  - supported toolchain
  - native dependency source
  - CI coverage status
  - known risks
- Audit all native scripts under `rsrc/native/`.
- Audit all workflows under `.github/workflows/`.
- Audit and classify the duplicate `github-workflows/` directory:
  - obsolete and deletable
  - still useful and needs migration
- Record current Raylib version assumptions across:
  - README
  - workflows
  - install scripts
  - examples
  - shard metadata

### Deliverables

- support matrix markdown
- issue list for stale scripts/workflows/docs

### Acceptance criteria

- there is one written source of truth for current support status
- every script/workflow that still assumes Raylib `5.0` is identified

## Phase 1: Modernize CI and define support gates

### Objective

Make CI the basis for support claims.

### Tasks

- Add a macOS workflow in `.github/workflows/`.
- Modernize existing Ubuntu and Windows workflows to current action versions.
- Split CI into at least these job categories:
  - `binding-compile`
  - `smoke-core`
  - `smoke-audio`
  - `build-examples`
- Add a platform matrix where sensible:
  - `ubuntu-latest`
  - `macos-latest`
  - `windows-latest`
- Ensure CI validates:
  - `shards install`
  - `crystal spec`
  - direct `require "raylib-cr"` compile
  - direct `require "raylib-cr/audio"` compile
  - direct `require "raylib-cr/raygui"` compile
  - direct `require "raylib-cr/rlgl"` compile
  - direct `require "raylib-cr/lights"` compile

### Recommended smoke targets

- `spec/raylib-cr_spec.cr`
- a tiny non-interactive window lifecycle smoke
- a tiny audio init/close smoke
- a tiny import-only smoke for optional submodules

### Notes

- For CI, prefer very small dedicated smoke programs over running all examples.
- Example builds are still useful, but they should not be the only signal.

### Acceptance criteria

- macOS, Ubuntu, and Windows all have at least one passing CI lane
- CI failures point to a narrow category instead of one giant example-build job

## Phase 2: Replace outdated install guidance with supported OS paths

### Objective

Stop presenting invasive hand-built system install scripts as the default user path.

### macOS tasks

- Replace the primary README macOS path with Homebrew-based setup:
  - `brew install crystal raylib`
- Document any additional requirements:
  - `pkg-config` if needed
  - Xcode command line tools
- Explicitly document how Darwin framework linking interacts with the Homebrew-installed Raylib library.
- Demote `rsrc/native/mac/*.sh` from primary install path to:
  - legacy fallback
  - or remove if fully obsolete

### Ubuntu/Linux tasks

- Prefer package-manager installation where practical.
- If source-build fallback remains, update it to Raylib `5.5`.
- Remove or de-emphasize scripts that copy shared libs into `/usr/lib` and `/lib`.
- Document the exact Linux packages needed for:
  - build
  - runtime
  - audio

### Windows tasks

- Decide and document the primary Windows support lane:
  - MSVC
  - MSYS2
  - or both with one marked primary
- If both are kept:
  - document each clearly
  - ensure each has CI coverage or demote one to best-effort
- Remove outdated assumptions around manual `C:\raylib` installs if they are no longer the preferred path.

### Acceptance criteria

- README gives one primary installation path per OS
- legacy scripts are clearly marked as fallback or removed
- no primary documentation path still references Raylib `5.0`

## Phase 3: Harden macOS specifically

### Objective

Turn macOS from historical best-effort into a CI-backed supported target.

### Tasks

- Add macOS CI build and smoke jobs.
- Add a dedicated macOS smoke sample that validates:
  - `init_window`
  - `close_window`
  - `toggle_fullscreen`
  - mouse coordinate retrieval
- Add a macOS audio smoke sample:
  - `InitAudioDevice`
  - `CloseAudioDevice`
  - optionally `LoadAudioStream` / `UnloadAudioStream`
- Validate `raygui` import/compile on macOS.
- Validate `miniaudio` compile-time size detection on macOS runners.

### Specific risks to watch

- Retina / DPI behavior
- fullscreen/window size vs render size expectations
- framework link flags
- audio struct sizing and callback ABI

### Acceptance criteria

- macOS CI passes for:
  - core smoke
  - audio smoke
  - optional module compile smoke
- README support language can be upgraded from `Weak/Broken`

## Phase 4: Improve Linux and Windows to the same standard

### Objective

Avoid fixing macOS while leaving the rest of the support story uneven.

### Linux tasks

- Convert Linux CI from `build examples only` to layered smoke + examples.
- Verify package-manager-based install path in CI.
- Validate `audio.cr` on Linux, since miniaudio sizing is also relevant there.
- Confirm `raygui` shared-lib expectations are still correct.

### Windows tasks

- Decide whether MSVC or MSYS2 is the primary target.
- Add compile smoke for whichever path is primary.
- If MSYS2 remains supported:
  - add CI or document it as best-effort
- Reduce reliance on vendored binary blobs if possible.
- Validate that optional modules compile under the chosen Windows toolchain.

### Acceptance criteria

- all claimed supported OSes have the same baseline smoke coverage
- support statements distinguish clearly between primary and secondary Windows paths

## Phase 5: Audio risk reduction

### Objective

Keep the current audio binding working while reducing its risk profile.

### Tasks

- Add explicit CI coverage for `require "raylib-cr/audio"`.
- Add a small compile/runtime smoke that exercises:
  - `InitAudioDevice`
  - `CloseAudioDevice`
  - `LoadAudioStream`
  - `UnloadAudioStream`
- Document the compile-time miniaudio size detection mechanism in README or a developer doc.
- Add a failure-mode note:
  - what users should inspect if audio compilation fails on a platform
- Review whether the generated struct-size approach can be made more deterministic:
  - toolchain assumptions
  - fallback values
  - error messages

### Acceptance criteria

- audio support is explicitly tested in CI on all supported OSes
- maintainers have clear debugging guidance for miniaudio-size failures

## Phase 6: Documentation rewrite

### Objective

Make the support story readable, accurate, and maintainable.

### Tasks

- Rewrite `README.md` support section to use support tiers:
  - `Supported`
  - `Best effort`
  - `Experimental`
- Replace `Weak/Broken support` phrasing with evidence-based wording.
- Add a short matrix:
  - OS
  - install path
  - CI status
  - notes
- Update install instructions to:
  - current Raylib version
  - current Crystal version expectations
  - current package manager commands
- Add a short maintainer section:
  - how to update Raylib version assumptions
  - how to validate all OSes

### Acceptance criteria

- README matches the actual repo behavior
- no stale Raylib `5.0` instructions remain in primary docs

## Phase 7: Repository cleanup

### Objective

Remove support ambiguity caused by stale assets.

### Tasks

- Delete or archive the duplicate `github-workflows/` directory if obsolete.
- Remove or clearly mark legacy install scripts that are no longer primary.
- Review whether vendored binaries like `rsrc/native/windows/*.dll` should remain in repo.
- Ensure examples and scripts reference the same supported installation approach.

### Acceptance criteria

- there is one canonical workflow location
- there is one canonical install story per OS

## Test Strategy

## Core shard tests

- keep current Crystal specs
- add compile/runtime smoke specs only where they prove support claims

### Recommended smoke programs

- `smoke_core.cr`
  - `require "raylib-cr"`
  - init and close a window
- `smoke_audio.cr`
  - `require "raylib-cr/audio"`
  - init and close audio device
- `smoke_modules.cr`
  - require `raygui`, `rlgl`, `lights`

## CI matrix

- Ubuntu:
  - core
  - audio
  - optional modules
  - examples build
- macOS:
  - core
  - audio
  - optional modules
- Windows:
  - core
  - optional modules
  - audio if the toolchain is stable enough in CI

## Manual verification

At least once before changing the README support tier:

- macOS:
  - real window opens
  - fullscreen toggles
  - mouse coordinates behave sensibly
  - audio device init/close works
- Windows:
  - import/build path works on the documented toolchain
- Linux:
  - import/build path works on documented distro/package set

## Implementation Order

1. Phase 0 baseline
2. Phase 1 CI modernization
3. Phase 2 install/docs modernization
4. Phase 3 macOS hardening
5. Phase 4 Linux/Windows parity improvements
6. Phase 5 audio risk reduction
7. Phase 6 README/support rewrite
8. Phase 7 cleanup

## Proposed Deliverables by PR

### PR 1: CI foundation

- add macOS workflow
- modernize Ubuntu/Windows workflows
- add smoke jobs

### PR 2: Install/documentation modernization

- README rewrite for installation
- de-emphasize legacy scripts
- update all 5.0 references to 5.5

### PR 3: macOS support hardening

- macOS smoke validation
- any Darwin-specific shard fixes justified by CI

### PR 4: Linux/Windows parity

- clean up Windows primary path
- Linux package-manager-first path
- optional module validation

### PR 5: audio hardening

- audio smoke coverage
- miniaudio docs and diagnostics

### PR 6: repository cleanup

- remove stale workflow/install assets
- tighten support matrix wording

## Risks

- CI may expose real platform differences that require small binding fixes.
- Windows support may need a decision to narrow scope rather than pretending to support every toolchain equally.
- macOS fullscreen/input issues may still turn out to be downstream engine issues rather than shard issues; the shard plan should validate the binding, not absorb every consumer bug.
- audio may remain the least stable platform surface until deeper architectural work is done.

## Success Criteria

This plan is complete when:

- macOS, Ubuntu, and Windows each have CI-backed smoke coverage
- README support claims are evidence-based
- the default install paths are modern and non-invasive
- the shard no longer documents Raylib `5.0` as the default native baseline
- maintainers can answer `is macOS supported?` with CI-backed confidence instead of historical caution
