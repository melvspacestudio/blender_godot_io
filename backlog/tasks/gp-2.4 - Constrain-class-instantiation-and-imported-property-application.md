---
id: GP-2.4
title: Constrain class instantiation and imported property application
status: To Do
assignee: []
created_date: '2026-06-08 15:34'
updated_date: '2026-06-08 16:45'
labels:
  - audit
  - godot
  - safety
dependencies: []
references:
  - godot/godot_gltf_pipeline_addon/modifiers/classes/class_node_modifier.gd
  - godot/godot_gltf_pipeline_addon/modifiers/classes/factories/class_factory.gd
  - >-
    godot/godot_gltf_pipeline_addon/modifiers/classes/utility/class_modifier_context.gd
  - godot/godot_gltf_pipeline_addon/utility/node_utility.gd
parent_task_id: GP-2
priority: high
ordinal: 6000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Make class instantiation and imported property application robust while preserving the current metadata-driven behavior.

Current behavior:
- `GGP_ClassNodeModifier` derives a class from `extras.class_name` or the glTF node name.
- If `ClassDB.class_exists(classname)` and the class is not in `blacklist`, the modifier instantiates it through `GGP_ClassFactory`.
- If the glTF node has a mesh, the requested class is created as a parent and an `ImporterMeshInstance3D` child named `MeshInstance3D` is added.
- Extras keys that match property names are set directly on the created node.

Decisions for this task:
- Preserve the current blacklist-based policy. Do not add an allowlist in this task.
- If the requested class cannot be instantiated, is not a `Node`, or otherwise fails validation, keep the original imported node and warn with the class name and reason.
- Preserve mesh-node behavior: a mesh-backed class node remains a generated class parent with a child `ImporterMeshInstance3D` named `MeshInstance3D`.
- Preserve property application from extras for keys that match writable properties, but make it safe and quiet.
- Reserved metadata keys used by the pipeline, such as `class_name` and `geometry_nodes`, must not be applied as node properties.
- Unknown extras keys should be skipped without noisy normal-path `print()` output.
- If a matching property cannot be assigned safely because of type mismatch, invalid resource reference, or conversion failure, skip only that property and `push_warning()` with class name, property name, and value type/context.
- Property application should use shared safe conversion/resource-loading logic compatible with the intended behavior of `GGP_NodeUtility._recursive_set()`: nested property paths still work, `res://` and `uid://` strings are handled safely, invalid resource references do not crash, and the helper returns enough success/failure context for callers to warn only on actionable malformed data.
- Do not preserve current normal-path debug output from `GGP_NodeUtility._recursive_set()` or class/property handling. The shared helper path should be quiet on successful assignments and unknown skipped keys.
- Add focused GdUnit tests for blacklist behavior, non-Node/uninstantiable class fallback, reserved-key skipping, safe property application/conversion, failed property warning behavior, and mesh-child preservation.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 The class policy remains blacklist-based; no allowlist is introduced in this task.
- [ ] #2 Requested classes that cannot be instantiated or do not produce a `Node` leave the original imported node unchanged and warn with class name and reason.
- [ ] #3 Existing mesh-backed class behavior is preserved: the generated class node is the parent and an `ImporterMeshInstance3D` child named `MeshInstance3D` is added.
- [ ] #4 Extras property application still supports matching node properties, but reserved pipeline metadata keys such as `class_name` and `geometry_nodes` are never applied as properties.
- [ ] #5 Unknown extras keys are skipped without normal-path `print()` output or warning spam.
- [ ] #6 Property assignment failures caused by type mismatch, invalid resource reference, or conversion failure skip only that property and emit a contextual warning.
- [ ] #7 Property application uses shared safe conversion/resource-loading logic compatible with the intended `GGP_NodeUtility._recursive_set()` behavior, including nested property paths plus safe `res://` and `uid://` handling, without keeping current normal-path debug prints.
- [ ] #8 The shared property-application path reports enough success/failure context for callers to warn on actionable malformed data without warning for unknown skipped extras keys.
- [ ] #9 Normal-path class/property processing no longer prints every set/skip operation.
- [ ] #10 Existing collision/reflection-probe examples still import as intended under the hardened behavior.
- [ ] #11 Focused GdUnit tests cover blacklist behavior, non-Node/uninstantiable class fallback, reserved-key skipping, safe property application/conversion, failed property warning behavior, and mesh-child preservation.
- [ ] #12 Godot import validation is run when available; if unavailable, completion notes record the exact missing executable or failure.
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Task grooming decisions recorded from user input on 2026-06-08: keep current behavior by default. Do not add allowlist; keep blacklist policy. Non-Node or uninstantiable classes should keep original imported node and warn. Skip reserved metadata keys. Unknown extras keys should not spam logs. Failed matching-property assignment should warn and skip only that property. Use shared safe conversion/resource-loading rules compatible with the intended behavior of `GGP_NodeUtility._recursive_set()`, but do not preserve current normal-path debug prints or unsafe failure behavior. The helper path should support nested property paths, safe `res://` and `uid://` handling, and enough success/failure context for callers. Preserve mesh-child behavior. Add focused GdUnit tests.
<!-- SECTION:NOTES:END -->
