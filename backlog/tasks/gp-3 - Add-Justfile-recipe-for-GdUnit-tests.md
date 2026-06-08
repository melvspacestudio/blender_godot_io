---
id: GP-3
title: Add Justfile recipe for GdUnit tests
status: Done
assignee: []
created_date: '2026-06-08 19:08'
updated_date: '2026-06-08 19:13'
labels:
  - tooling
  - tests
dependencies: []
modified_files:
  - Justfile
  - .env
priority: low
ordinal: 10000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Document and automate the command needed to run the example Godot project's GdUnit test suite from the repository root.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 The repository has a Justfile recipe that runs the GdUnit tests for example/game.
- [x] #2 The recipe works from the repository root and uses the Godot executable in a way compatible with the existing GdUnit setup.
- [x] #3 Verification results are reported, including whether Godot was available locally.
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
Add a root Justfile that delegates to the existing GdUnit4 runner in example/game/addons/gdUnit4/runtest.sh. The recipe should be runnable from the repository root, discover common Godot executable names, allow GODOT_BIN to override discovery, and keep the vendored runner responsible for GdUnit-specific CLI arguments.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Inspected example/game/addons/gdUnit4/runtest.sh and confirmed it must run from example/game and requires either GODOT_BIN or --godot_binary. Added root recipes: default lists recipes, test aliases gdunit, and gdunit discovers godot4.7/godot4/godot or uses GODOT_BIN before invoking the vendored runner.

Validation: just --list passed; just --dry-run gdunit passed; just gdunit failed at the intended guard because no godot, godot4, godot4.7 command and no GODOT_BIN were available in this shell. No full GdUnit runtime execution was possible locally.

Follow-up after dotenv setup: added root `.env` with `GODOT_BIN` pointing to Godot Version Manager's 4.7 beta5 binary. Updated `just gdunit` to pass `-a res://tests`; without that GdUnit only printed help and exited 0. Re-ran `just gdunit`: it now discovers and executes 13 tests across 3 suites, but exits 100 due to an existing prefab test failure (`test_successful_normal_replacement_preserves_extension_replace_behavior` expected `$TestPrefab` and got `$TestPrefab2`).
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Added a repository-root Justfile for running the example project's GdUnit suite. `just gdunit` resolves the Godot executable from `GODOT_BIN` or common command names (`godot4.7`, `godot4`, `godot`), then runs the vendored `example/game/addons/gdUnit4/runtest.sh` from `example/game`; `just test` aliases the same recipe.

Validation: `just --list` and `just --dry-run gdunit` passed. `just gdunit` reached the recipe's missing-Godot guard and exited with the expected error because Godot is not installed on PATH and `GODOT_BIN` is unset in this environment, so the actual GdUnit suite could not be run locally.

Follow-up: dotenv loading is now exercised with a root `.env` pointing `GODOT_BIN` at the Godot Version Manager 4.7 beta5 binary. The GdUnit recipe was corrected to invoke `-a res://tests`; the suite now runs instead of printing help. Current result: 13 tests discovered/executed, 12 pass and 1 prefab test fails with `$TestPrefab` vs `$TestPrefab2`.
<!-- SECTION:FINAL_SUMMARY:END -->
