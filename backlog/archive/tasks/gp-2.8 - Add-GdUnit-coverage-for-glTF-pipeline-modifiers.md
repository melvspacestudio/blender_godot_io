---
id: GP-2.8
title: Add GdUnit coverage for glTF pipeline modifiers
status: To Do
assignee: []
created_date: '2026-06-08 15:39'
labels:
  - audit
  - testing
  - godot
  - gdunit
dependencies: []
references:
  - example/game/project.godot
  - example/game/addons/gdUnit4
  - godot/godot_gltf_pipeline_addon/config/import_config.gd
  - godot/godot_gltf_pipeline_addon/modifiers
  - >-
    backlog/tasks/gp-2.5 -
    Add-repeatable-validation-for-the-import-pipeline-examples.md
parent_task_id: GP-2
priority: high
ordinal: 10000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
GdUnit4 is now installed in the example project and enabled via `res://addons/gdUnit4/plugin.cfg` in `example/game/project.godot`. Add a real GdUnit test suite for the Godot glTF pipeline add-on instead of relying only on manual/headless load validation. Tests should live in the example project, exercise source add-on code through the symlinked `res://addons/godot_gltf_pipeline_addon`, and avoid treating the vendored GdUnit4 add-on internals as project code.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 A GdUnit test directory is added under the example project with focused suites for pipeline add-on behavior, not for vendored third-party add-ons.
- [ ] #2 Tests cover import config discovery/order/de-duplication behavior or a documented seam for it.
- [ ] #3 Tests cover at least one modifier-level edge case from the audit, such as missing prefab handling, texture/material path safety, or class-instantiation policy.
- [ ] #4 A documented command runs the GdUnit suite headlessly from `example/game`, using the installed GdUnit4 runner.
- [ ] #5 The GdUnit command is run when Godot is available; if it cannot be run, the task records the exact missing executable or failure.
- [ ] #6 The test task coordinates with GP-2.5 so general validation docs reference the GdUnit suite once it exists.
<!-- AC:END -->
