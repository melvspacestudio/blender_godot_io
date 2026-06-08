---
id: GP-2.1
title: Make import config resolution explicit and deterministic
status: Done
assignee:
  - Codex
created_date: '2026-06-08 15:34'
updated_date: '2026-06-08 17:16'
labels:
  - audit
  - godot
  - import-config
dependencies: []
references:
  - godot/godot_gltf_pipeline_addon/config/import_config.gd
  - godot/godot_gltf_pipeline_addon/extension/ggp_gltf_extension.gd
  - example/game/project.godot
  - example/game/global_import_config.tres
modified_files:
  - example/game/project.godot
  - godot/godot_gltf_pipeline_addon/config/import_config.gd
  - example/game/tests/import_config/import_config_test.gd
  - example/game/tests/import_config/import_config_test.gd.uid
  - example/game/tests/import_config/recording_modifier.gd
  - example/game/tests/import_config/recording_modifier.gd.uid
  - example/game/tests/import_config/fixtures/order/import_config.tres
  - example/game/tests/import_config/fixtures/order/child/import_config.tres
  - example/game/tests/import_config/fixtures/order/child/not_import_config.tres
  - example/game/tests/import_config/fixtures/duplicates/asset/a_config.tres
  - example/game/tests/import_config/fixtures/duplicates/asset/b_config.tres
  - example/game/tests/import_config/fixtures/dedup/import_config.tres
  - example/game/tests/import_config/fixtures/dedup/child/import_config.tres
parent_task_id: GP-2
priority: high
ordinal: 3000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Make `GGP_ImportConfig.get_config(path)` deterministic and explicitly documented.

Current behavior: the resolver scans every `.tres`/`.res` in the import folder, appends parent-folder configs recursively, and depends on `ResourceLoader.list_directory(path)` order. `example/game/project.godot` also contains stale setting `godot_gltf_pipeline/configuration_path="res://config.tres"`; no such file exists and the extension does not read this setting.

Decisions for this task:
- Remove `godot_gltf_pipeline/configuration_path` from the example project. Do not implement project-setting-based global config loading in this task.
- Continue scanning all `.tres` and `.res` files in each folder for `GGP_ImportConfig` resources.
- Enforce one effective config per folder: if a folder contains multiple `GGP_ImportConfig` resources, sort their resource paths lexicographically, `push_warning()` with the folder and all discovered config paths, and apply only the first sorted config.
- Apply configs in nearest-first order: the imported asset folder config runs before parent folder configs. With one-modifier-per-global-script de-duplication, this means local configs override broader parent/global configs for duplicate modifier scripts.
- Keep the existing one-modifier-per-global-script de-duplication behavior intentional.
- Add focused GdUnit coverage in this task for config ordering, duplicate config warning/selection behavior, and modifier de-duplication behavior. Broader GdUnit coverage is not tracked as a separate GP-2 child task; each implementation task owns its focused tests and validation expectations.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 `example/game/project.godot` no longer contains the stale `godot_gltf_pipeline/configuration_path` setting or an empty `[godot_gltf_pipeline]` section introduced only for that setting.
- [x] #2 `GGP_ImportConfig.get_config(path)` scans all `.tres` and `.res` files in each relevant folder and only treats loaded `GGP_ImportConfig` resources as configs.
- [x] #3 Config resolution order is deterministic and documented in code or repository docs: nearest asset folder first, then each parent folder toward `res://`.
- [x] #4 If multiple `GGP_ImportConfig` resources exist in one folder, the resolver sorts matching config paths lexicographically, warns with all matching paths, and applies only the first sorted config for that folder.
- [x] #5 The GLTF extension keeps one-modifier-per-global-script de-duplication semantics so local/nearest configs win over broader configs for duplicate modifier scripts.
- [x] #6 Focused GdUnit tests are added under the example project to cover nearest-first ordering, multiple-config warning/selection behavior, and duplicate modifier de-duplication behavior.
- [x] #7 The GdUnit test command for this suite is documented and run when Godot is available; if it cannot be run, the task completion notes record the exact missing executable or failure.
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
# GP-2.1 Deterministic Import Config Resolution

## Summary
Implement deterministic `GGP_ImportConfig.get_config(path)` behavior, remove the stale example project setting, and add focused GdUnit coverage for ordering, duplicate config selection/warning, and modifier de-duplication.

## Key Changes
- Keep `GGP_ImportConfig.get_config(path) -> GGP_ImportConfig.List` unchanged.
- Update `import_config.gd` so each folder scans `.tres` and `.res` candidates, loads only `GGP_ImportConfig` resources, sorts matching config paths lexicographically, warns when more than one config is found, and applies only the first sorted config.
- Preserve nearest-first resolution: asset folder, then parent folders up to `res://`.
- Add a short code comment documenting the resolution rules.
- Remove `[godot_gltf_pipeline] configuration_path="res://config.tres"` from `example/game/project.godot`; remove the section entirely if empty.
- Keep existing one-modifier-per-global-script behavior in `ggp_gltf_extension.gd`; optionally factor repeated enabled/dedup logic while preserving semantics.

## Tests
- Add GdUnit suite under `example/game/tests/import_config/` with minimal tracked fixture configs/resources.
- Cover nearest-first ordering, non-config `.tres` ignore behavior, duplicate config warning and lexicographic selection, and duplicate modifier de-duplication where nearest/local wins.
- Run `cd example/game && GODOT_BIN=/path/to/godot ./addons/gdUnit4/runtest.sh -a res://tests/import_config/import_config_test.gd -c --ignoreHeadlessMode` and `godot --headless --path example/game --quit` when Godot is available; otherwise record exact missing executable names.

## Assumptions
- Do not implement project-setting-based global config loading.
- Do not introduce a diagnostics helper; duplicate-config warning uses `push_warning()` directly so GP-2.7 owns diagnostics/log cleanup later.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Task grooming decisions recorded from user input on 2026-06-08: remove the unused project setting instead of implementing it; keep scanning all `.tres/.res`; nearest/local configs override parent/global configs via existing de-duplication; enforce single effective config per folder with a warning; include focused GdUnit tests in this task.

Implemented GP-2.1 according to the approved plan. Validation run: `git diff --check` passed; stale setting search for `configuration_path=`, `[godot_gltf_pipeline]`, and `res://config.tres` across project/config/test docs returned no matches. Godot runtime validation could not be completed because `godot`, `godot4`, and `godot4.7` are not on PATH. Attempted `godot --headless --path example/game --quit` failed with `godot: command not found`; attempted `cd example/game && ./addons/gdUnit4/runtest.sh -a res://tests/import_config/import_config_test.gd -c --ignoreHeadlessMode` failed because `GODOT_BIN` was not specified.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Implemented deterministic import config resolution for GP-2.1.

Changes:
- `GGP_ImportConfig.get_config(path)` now scans `.tres`/`.res` resources deterministically, filters to loaded `GGP_ImportConfig` resources, sorts matching paths lexicographically, warns when a folder has multiple configs, and applies only the first sorted config per folder.
- Resolution remains nearest-first from the imported asset folder toward `res://`, preserving existing one-modifier-per-global-script behavior in the GLTF extension so local configs win.
- Removed the stale `godot_gltf_pipeline/configuration_path="res://config.tres"` setting and empty section from the example project.
- Added focused GdUnit coverage and fixtures for nearest-first ordering, ignored non-config resources, duplicate config warning/selection, and duplicate modifier de-duplication.

Validation:
- `git diff --check` passed.
- Stale setting/reference search returned no matches.
- Godot/GdUnit runtime validation was not run because `godot`, `godot4`, and `godot4.7` were not available on PATH; the GdUnit wrapper also reported that `GODOT_BIN` was not specified.
<!-- SECTION:FINAL_SUMMARY:END -->
