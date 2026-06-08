---
id: GP-2.7
title: Clean modifier helper contracts and import logging
status: To Do
assignee: []
created_date: '2026-06-08 15:35'
updated_date: '2026-06-08 16:57'
labels:
  - audit
  - godot
  - maintenance
dependencies: []
references:
  - godot/godot_gltf_pipeline_addon/modifiers/base/node_modifier.gd
  - godot/godot_gltf_pipeline_addon/utility/mesh/importer_mesh_apply_later.gd
  - godot/godot_gltf_pipeline_addon/extension/ggp_gltf_extension.gd
  - >-
    godot/godot_gltf_pipeline_addon/modifiers/collision/collision_node_modifier.gd
  - godot/godot_gltf_pipeline_addon/modifiers/classes/factories/class_factory.gd
  - godot/godot_gltf_pipeline_addon/utility/diagnostics.gd
parent_task_id: GP-2
priority: medium
ordinal: 9000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Clean helper contracts and normal-path logging while preserving current import behavior.

Current issues:
- `GGP_NodeModifier._apply_later(node, properties)` accepts a property dictionary but ignores it and always writes `gi_mode`.
- `GGP_ImporterMeshInstance3D_ApplyLater` silently applies only keys that exist on the parent.
- The GLTF extension prints duplicate-modifier skip messages during normal, intentional de-duplication.
- Other normal-path print cleanup is already owned by focused tasks: GP-2.2 for specular/asset processors, GP-2.3 for prefab missing-resource behavior, and GP-2.4 for class/property application.
- `GGP_CollissionNodeModifier` has a misspelled public class name.

Decisions for this task:
- Keep `_apply_later(node, properties)` name/signature and make it honor the provided dictionary by merging all provided properties into the `_ApplyLater.properties` dictionary.
- Preserve current `_ApplyLater` behavior of silently ignoring property keys that do not exist on the parent node. Explanation: queued apply-later properties may be harmless compatibility no-ops across Godot versions or parent node types; warning for every missing property could make imports noisy.
- Add a diagnostics helper for this add-on, such as `GGP_Diagnostics`, with a static warning signal named `warning_emitted(message: String, context: Dictionary)`. Warning helpers owned by this task should emit that signal and also log the warning through Godot's warning path, so GdUnit can listen to the signal without scraping console output.
- Actionable failures owned by this task, such as missing/invalid `_ApplyLater` parent context if encountered, should warn through the diagnostics helper instead of crashing.
- Remove normal-path duplicate-modifier `print()` messages from the GLTF extension. De-duplication is intentional and should not log on successful imports.
- Keep this task scoped to helper contract cleanup, duplicate-modifier log cleanup, diagnostics helper introduction, and the collision class-name typo. Do not duplicate print/log cleanup already owned by GP-2.2, GP-2.3, or GP-2.4.
- Rename `GGP_CollissionNodeModifier` to the correctly spelled `GGP_CollisionNodeModifier` and update uses/resources in this repository's example project. Do not add a migration strategy, alias class, compatibility shim, or broader support for external resources that still reference the misspelled class name.
- Avoid unrelated Godot metadata churn while updating the repository-owned example uses.
- Add focused GdUnit tests for `_apply_later` property merge/application behavior, diagnostics signal emission for actionable warnings, and duplicate-modifier de-duplication/log-silence behavior.
- Run Godot validation when available; record exact missing executable or failure if it cannot be run.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 `_apply_later(node, properties)` keeps its public helper name/signature and merges all provided properties into the child `_ApplyLater.properties` dictionary.
- [ ] #2 Existing `_ApplyLater` behavior of silently ignoring keys that are not valid properties on the parent is preserved and documented as intentional compatibility behavior.
- [ ] #3 A diagnostics helper for the add-on is introduced, such as `GGP_Diagnostics`, with a static warning signal named `warning_emitted(message: String, context: Dictionary)`.
- [ ] #4 Warnings emitted through the diagnostics helper both emit `warning_emitted` and log through Godot's warning path, giving GdUnit a signal it can listen to without scraping console output.
- [ ] #5 Actionable `_ApplyLater` failures, such as missing or invalid parent context if encountered, produce concise diagnostics warnings instead of crashes.
- [ ] #6 Normal-path duplicate-modifier `print()` messages are removed from GLTF extension import callbacks while keeping de-duplication semantics unchanged.
- [ ] #7 This task does not duplicate print/log cleanup owned by GP-2.2, GP-2.3, or GP-2.4.
- [ ] #8 `GGP_CollissionNodeModifier` is renamed to `GGP_CollisionNodeModifier`, and repository-owned example uses/resources are updated to the corrected class name.
- [ ] #9 No migration strategy, alias class, or compatibility shim is added for external resources that may still reference `GGP_CollissionNodeModifier`.
- [ ] #10 The collision class-name cleanup avoids unrelated Godot metadata churn beyond the repository-owned example updates needed for the rename.
- [ ] #11 Focused GdUnit tests cover `_apply_later` property merge/application behavior and diagnostics signal emission for actionable warnings.
- [ ] #12 Focused GdUnit tests or static/source assertions cover duplicate-modifier de-duplication and removal of normal-path duplicate-modifier `print()` output.
- [ ] #13 Existing collision import examples still load/import as intended after the class-name typo cleanup.
- [ ] #14 Godot headless/editor validation is run when available; if unavailable, completion notes record the exact missing executable or failure.
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Task grooming decisions recorded from user input on 2026-06-08: make `_apply_later` honor and merge provided properties; preserve silent skip for invalid parent properties and document why; add an add-on diagnostics helper with static signal `warning_emitted(message: String, context: Dictionary)` for actionable warnings, where the helper emits the signal and logs through Godot's warning path so GdUnit can listen; remove duplicate-modifier normal-path prints; avoid overlapping print cleanup owned by GP-2.2/GP-2.3/GP-2.4; rename the misspelled collision public class name and update repository-owned example uses/resources only. No migration strategy, alias class, or compatibility shim should be added for external references to the misspelled class. Avoid unrelated Godot metadata churn. Add focused GdUnit tests for `_apply_later`, diagnostics warning signal emission, and duplicate de-duplication/log-silence behavior.
<!-- SECTION:NOTES:END -->
