---
id: GP-2.1
title: Make import config resolution explicit and deterministic
status: To Do
assignee: []
created_date: '2026-06-08 15:34'
updated_date: '2026-06-08 16:58'
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
- [ ] #1 `example/game/project.godot` no longer contains the stale `godot_gltf_pipeline/configuration_path` setting or an empty `[godot_gltf_pipeline]` section introduced only for that setting.
- [ ] #2 `GGP_ImportConfig.get_config(path)` scans all `.tres` and `.res` files in each relevant folder and only treats loaded `GGP_ImportConfig` resources as configs.
- [ ] #3 Config resolution order is deterministic and documented in code or repository docs: nearest asset folder first, then each parent folder toward `res://`.
- [ ] #4 If multiple `GGP_ImportConfig` resources exist in one folder, the resolver sorts matching config paths lexicographically, warns with all matching paths, and applies only the first sorted config for that folder.
- [ ] #5 The GLTF extension keeps one-modifier-per-global-script de-duplication semantics so local/nearest configs win over broader configs for duplicate modifier scripts.
- [ ] #6 Focused GdUnit tests are added under the example project to cover nearest-first ordering, multiple-config warning/selection behavior, and duplicate modifier de-duplication behavior.
- [ ] #7 The GdUnit test command for this suite is documented and run when Godot is available; if it cannot be run, the task completion notes record the exact missing executable or failure.
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Task grooming decisions recorded from user input on 2026-06-08: remove the unused project setting instead of implementing it; keep scanning all `.tres/.res`; nearest/local configs override parent/global configs via existing de-duplication; enforce single effective config per folder with a warning; include focused GdUnit tests in this task.
<!-- SECTION:NOTES:END -->
