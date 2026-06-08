---
id: GP-2.6
title: Align README and example project with implemented scope
status: To Do
assignee: []
created_date: '2026-06-08 15:34'
updated_date: '2026-06-08 16:28'
labels:
  - audit
  - docs
  - example-project
dependencies: []
references:
  - README.md
  - example/game/project.godot
  - example/game/addons
  - godot/godot_gltf_pipeline_addon/plugin.cfg
parent_task_id: GP-2
priority: medium
ordinal: 8000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Align README and documentation with the implemented repository scope while preserving current project files unless another task explicitly changes them.

Current issue: the README describes both a Blender add-on and a Godot add-on, but the repository currently contains the Godot add-on source under `godot/godot_gltf_pipeline_addon/`. The example project is useful as a reference fixture, but this task should not document every enabled example/editor add-on in detail.

Decisions for this task:
- Documentation-only task. Do not disable, remove, or reorganize example project add-ons as part of this task.
- Remove Blender add-on claims from current-scope documentation for now. The README should describe the implemented Godot glTF pipeline add-on and avoid presenting a Blender add-on as currently available in this repository.
- Keep the example project documentation high-level: note that `example/game` can be read/opened to understand how to use the add-on and its import configs. Do not add a detailed classification of every enabled example/editor add-on.
- Document the source add-on location and symlink relationship explicitly: `example/game/addons/godot_gltf_pipeline_addon` points to `godot/godot_gltf_pipeline_addon`.
- Remove stale documentation or README references to `godot_gltf_pipeline/configuration_path` / `res://config.tres` if present. The actual project setting cleanup is owned by GP-2.1, but docs should not introduce or preserve the stale setting.
- Do not add validation or test commands in this task.
- Keep the existing generated `.tscn` ownership message: generated asset customization scenes are intended to remain editable and should not be overwritten unless regeneration is intentional.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 README describes the current implemented scope as the Godot glTF pipeline add-on and does not claim a Blender add-on is currently provided by this repository.
- [ ] #2 README repository layout matches actual paths, including `godot/godot_gltf_pipeline_addon/` as the source add-on.
- [ ] #3 README explicitly documents that the example project uses a symlink from `example/game/addons/godot_gltf_pipeline_addon` to the source add-on directory.
- [ ] #4 Example project documentation stays high-level and says the example can be read/opened to understand add-on usage; it does not enumerate or classify every unrelated enabled add-on.
- [ ] #5 README and related docs do not mention the stale `godot_gltf_pipeline/configuration_path` / `res://config.tres` setting.
- [ ] #6 No validation/test commands are added by this task.
- [ ] #7 Documentation states generated `.tscn` asset customization scenes are editable and should not be overwritten unless regeneration is intentional.
- [ ] #8 No code, project settings, generated assets, or example add-ons are changed except documentation files needed for this task.
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Task grooming decisions recorded from user input on 2026-06-08: documentation-only; no Blender add-on for now; do not classify example-specific enabled add-ons; just note the example can be read/opened to understand usage; document the source add-on symlink; remove stale config path docs if present; do not add commands.
<!-- SECTION:NOTES:END -->
