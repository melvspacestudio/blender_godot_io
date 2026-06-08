---
id: GP-2.5
title: Add repeatable validation for the import pipeline examples
status: To Do
assignee: []
created_date: '2026-06-08 15:34'
updated_date: '2026-06-08 16:26'
labels:
  - audit
  - testing
  - godot
dependencies: []
references:
  - README.md
  - AGENTS.md
  - example/game/project.godot
  - godot/godot_gltf_pipeline_addon/extension/ggp_gltf_extension.gd
parent_task_id: GP-2
priority: medium
ordinal: 7000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
The repository currently relies on committed example scenes and manual Godot editor/headless checks; no project-level test harness was found. Import modifiers affect scene generation, resource saving, metadata, collisions, prefabs, lights, and materials, so regressions are hard to catch without a repeatable validation command.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 A documented validation command exists for loading or reimporting the example project in headless Godot.
- [ ] #2 The validation covers representative examples for collisions, materials, transform normalization, prefabs, and the full scene.
- [ ] #3 The command fails on missing script/resource/import errors and is suitable for local use or CI when Godot is installed.
- [ ] #4 Expected Godot version behavior is documented because the example project declares `4.7` features.
- [ ] #5 The task reports whether validation was actually run and which Godot executable/version was used.
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Dropped during task grooming on 2026-06-08 by user request. Project-level validation task is no longer tracked separately; GdUnit-focused coverage remains in GP-2.8 and per-task validation remains in the implementation tasks.
<!-- SECTION:NOTES:END -->
