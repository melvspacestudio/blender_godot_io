---
id: GP-2
title: Harden Godot glTF pipeline from audit findings
status: To Do
assignee: []
created_date: '2026-06-08 15:34'
labels:
  - audit
  - godot
  - gltf-pipeline
dependencies: []
priority: high
ordinal: 2000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Parent initiative for hardening the Godot glTF import add-on and example project after a static project audit. The source add-on lives under `godot/godot_gltf_pipeline_addon/` and is symlinked into `example/game/addons/godot_gltf_pipeline_addon`. The audit found risk around implicit import config discovery, unchecked asset writes, unsafe prefab/class replacement failure paths, lack of automated import validation, and drift between README/project settings and implemented behavior.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Child tasks cover the highest-risk audit findings with enough local context for independent implementation.
- [ ] #2 Each child task includes validation expectations appropriate to Godot import-pipeline changes.
- [ ] #3 The initiative is complete when child tasks are resolved or explicitly closed as no longer needed.
<!-- AC:END -->
