---
id: GP-1
title: Rename internal project paths and BGIO prefix to GGP
status: Done
assignee:
  - Codex
created_date: '2026-06-08 15:00'
updated_date: '2026-06-08 15:07'
labels:
  - rename
  - godot
  - maintenance
dependencies: []
modified_files:
  - AGENTS.md
  - README.md
  - example/game/project.godot
  - example/game/global_import_config.tres
  - example/game/examples/1_collisions/import_config.tres
  - example/game/examples/2_materials/import_config.tres
  - example/game/examples/2_materials/processors/material_debug_processor.gd
  - example/game/examples/3_transform/import_config.tres
  - example/game/examples/4_prefabs/import_config.tres
  - example/game/examples/5_full/import_config.tres
  - example/game/addons/godot_gltf_pipeline_addon
  - godot/godot_gltf_pipeline_addon
priority: medium
ordinal: 1000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Update the repository after the visible project rename to Godot - GLTF Pipeline by renaming internal add-on paths and GDScript prefixes from the old Blender Godot IO naming to the new GGP naming. Preserve Godot resource references, symlink behavior, and import pipeline behavior.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Godot add-on directory and example project add-on reference use the new Godot - GLTF Pipeline path naming.
- [x] #2 GDScript class_names, type references, and related symbols using the BGIO prefix are renamed to GGP consistently.
- [x] #3 Godot resource paths in project settings, plugin metadata, .tres, .import, and script icon references point at the renamed add-on path.
- [x] #4 Documentation and repository guidance refer to the new path and prefix where applicable.
- [x] #5 Verification is run or explicitly reported unavailable for loading the example Godot project.
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Rename add-on path `godot/blender_godot_io_addon` to `godot/godot_gltf_pipeline_addon` and replace the example symlink with `example/game/addons/godot_gltf_pipeline_addon -> ../../../godot/godot_gltf_pipeline_addon/`.
2. Update Godot resource references from `res://addons/blender_godot_io_addon/...` to `res://addons/godot_gltf_pipeline_addon/...` across project settings, `.tres`, `.import`, script icons, and plugin config.
3. Rename `[blender_godot_io]` project settings section to `[godot_gltf_pipeline]`.
4. Rename all `BGIO_*` GDScript class names, type annotations, constructors, constants, and references to `GGP_*`, including example processors.
5. Rename `BlenderGodotIO_GLTF_Extension` to `GGP_GLTF_Extension`.
6. Rename branded script files and matching `.uid` files: `setup/blender_godot_io.gd` to `setup/godot_gltf_pipeline.gd`, and `extension/blender_godot_io_gltf_extension.gd` to `extension/ggp_gltf_extension.gd`.
7. Update docs and agent guidance to use the new add-on path and `GGP` prefix.
8. Verify by searching for remaining old references, running Godot headless load checks if available, and reviewing `git diff` for rename-related scope only.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Initial inventory found old internal naming in the add-on directory path, example symlink, Godot plugin/project settings, GDScript class_names and type references, import_config.tres script_class metadata, resource ext_resource paths, the add-on logo .import source path, AGENTS.md, and one example debug processor. Internal resource UIDs can be preserved while paths/classes are renamed.

Implemented the approved rename: add-on directory and example symlink now use `godot_gltf_pipeline_addon`; Godot resource paths and project settings now use `res://addons/godot_gltf_pipeline_addon/...` and `[godot_gltf_pipeline]`; GDScript `BGIO_*` symbols now use `GGP_*`; `BlenderGodotIO_GLTF_Extension` is now `GGP_GLTF_Extension`; branded setup and extension script files were renamed with matching `.uid` files. Verification: old-reference searches outside Backlog task history returned no matches; `git diff --check` passed; Godot runtime checks could not be run because neither `godot` nor `godot4` is on PATH.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Renamed the internal Godot add-on identity to match Godot - GLTF Pipeline. The source add-on directory is now `godot/godot_gltf_pipeline_addon`, the example project symlink now points to it as `res://addons/godot_gltf_pipeline_addon`, and project/resource references were updated accordingly.

Renamed GDScript symbols from `BGIO_*` to `GGP_*`, changed the GLTF extension class to `GGP_GLTF_Extension`, and renamed the branded setup/extension scripts plus matching `.uid` files. Updated AGENTS/README guidance and switched the README logo to a relative path to avoid the old repository slug.

Verification performed: old-reference searches outside Backlog task history returned no matches, and `git diff --check` passed. Godot headless checks were not run because neither `godot` nor `godot4` is available on PATH.
<!-- SECTION:FINAL_SUMMARY:END -->
