---
id: GP-2.4
title: Constrain class instantiation and imported property application
status: Done
assignee: []
created_date: '2026-06-08 15:34'
updated_date: '2026-06-08 19:43'
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
modified_files:
  - godot/godot_gltf_pipeline_addon/modifiers/classes/class_node_modifier.gd
  - godot/godot_gltf_pipeline_addon/modifiers/classes/factories/class_factory.gd
  - >-
    godot/godot_gltf_pipeline_addon/modifiers/classes/factories/reflection_probe_class_factory.gd
  - >-
    godot/godot_gltf_pipeline_addon/modifiers/classes/utility/class_modifier_context.gd
  - godot/godot_gltf_pipeline_addon/utility/node_utility.gd
  - example/game/tests/classes/class_node_modifier_test.gd
  - example/game/tests/classes/class_node_modifier_test.gd.uid
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
- [x] #1 The class policy remains blacklist-based; no allowlist is introduced in this task.
- [x] #2 Requested classes that cannot be instantiated or do not produce a `Node` leave the original imported node unchanged and warn with class name and reason.
- [x] #3 Existing mesh-backed class behavior is preserved: the generated class node is the parent and an `ImporterMeshInstance3D` child named `MeshInstance3D` is added.
- [x] #4 Extras property application still supports matching node properties, but reserved pipeline metadata keys such as `class_name` and `geometry_nodes` are never applied as properties.
- [x] #5 Unknown extras keys are skipped without normal-path `print()` output or warning spam.
- [x] #6 Property assignment failures caused by type mismatch, invalid resource reference, or conversion failure skip only that property and emit a contextual warning.
- [x] #7 Property application uses shared safe conversion/resource-loading logic compatible with the intended `GGP_NodeUtility._recursive_set()` behavior, including nested property paths plus safe `res://` and `uid://` handling, without keeping current normal-path debug prints.
- [x] #8 The shared property-application path reports enough success/failure context for callers to warn on actionable malformed data without warning for unknown skipped extras keys.
- [x] #9 Normal-path class/property processing no longer prints every set/skip operation.
- [x] #10 Existing collision/reflection-probe examples still import as intended under the hardened behavior.
- [x] #11 Focused GdUnit tests cover blacklist behavior, non-Node/uninstantiable class fallback, reserved-key skipping, safe property application/conversion, failed property warning behavior, and mesh-child preservation.
- [x] #12 Godot import validation is run when available; if unavailable, completion notes record the exact missing executable or failure.
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
# Executed Implementation Plan

1. Preserve the blacklist-only class policy in `GGP_ClassNodeModifier` while separating requested class names from valid instantiable classes.
2. Keep ordinary derived node names quiet when they do not map to a class, but warn for explicit `extras.class_name` values that do not exist.
3. Route class generation through validated factory creation using `ClassDB.class_exists()` and `ClassDB.can_instantiate()`; if instantiation fails, returns a non-Node, or a factory returns no replacement, keep the original imported node and warn with class name and reason.
4. Preserve mesh-backed behavior by keeping the generated class node as parent and adding an `ImporterMeshInstance3D` child named `MeshInstance3D` with the imported mesh.
5. Replace direct extras assignment with shared `GGP_NodeUtility.apply_imported_property()` logic that reports `applied`, `skipped_unknown`, `skipped_reserved`, or `failed`.
6. Skip reserved pipeline metadata keys `class_name` and `geometry_nodes` silently; skip unknown extras silently; warn only for failed matching-property assignment, conversion, or resource loading.
7. Keep nested property paths and safe `res://`/`uid://` resource loading behavior, while removing normal-path `print()` output from class/property processing.
8. Preserve `GGP_ReflectionProbe_ClassFactory` behavior while making failed child probe creation non-destructive.
9. Add focused GdUnit coverage for blacklist handling, explicit invalid classes, non-Node classes, reserved/unknown extras, valid scalar/vector/resource/nested property assignment, invalid property/resource warnings, and mesh-child preservation.
10. Validate with `git diff --check`, `just gdunit`, and a headless example-project load using the same Godot binary discovery path as the Justfile.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Task grooming decisions recorded from user input on 2026-06-08: keep current behavior by default. Do not add allowlist; keep blacklist policy. Non-Node or uninstantiable classes should keep original imported node and warn. Skip reserved metadata keys. Unknown extras keys should not spam logs. Failed matching-property assignment should warn and skip only that property. Use shared safe conversion/resource-loading rules compatible with the intended behavior of `GGP_NodeUtility._recursive_set()`, but do not preserve current normal-path debug prints or unsafe failure behavior. The helper path should support nested property paths, safe `res://` and `uid://` handling, and enough success/failure context for callers. Preserve mesh-child behavior. Add focused GdUnit tests.

Implemented GP-2.4. Class generation now validates requested classes and preserves the original imported node on explicit invalid, non-instantiable, non-Node, or factory failure paths. Imported extras now use `GGP_NodeUtility.apply_imported_property()` with structured outcomes, reserved-key skipping, quiet unknown-key skipping, nested property support, safe resource loading, and contextual warnings for malformed matching properties. Added focused class modifier GdUnit coverage. Validation run: `git diff --check` passed; `just gdunit` passed 26 tests with 0 errors, 0 failures, 0 skipped, 0 orphans; direct `godot --headless --path example/game --quit` was unavailable by executable name, then the Justfile/.env Godot discovery path was used and the headless example project load passed. Godot printed known shutdown leak diagnostics after GdUnit exited 0.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Implemented hardened class instantiation and imported property application for the Godot glTF pipeline. The class modifier remains blacklist-based, keeps original imported nodes on invalid/non-Node/factory failure paths, and emits contextual warnings only for explicit actionable failures. The class factory now validates `ClassDB` instantiation, preserves mesh-backed generated parent behavior, and routes extras through shared safe property application. `GGP_NodeUtility` now exposes structured imported-property assignment with reserved-key skipping, quiet unknown-key skipping, nested property support, safe `res://`/`uid://` resource loading, vector/quaternion conversion, and failure context for warnings.

Added focused GdUnit coverage under `example/game/tests/classes/` for blacklist behavior, explicit invalid classes, non-Node fallback, reserved and unknown extras, valid scalar/vector/resource/nested assignments, failed assignment/resource warnings, and mesh-child preservation.

Validation: `git diff --check` passed; `just gdunit` passed 26 tests with 0 errors, 0 failures, 0 skipped, 0 orphans; direct `godot --headless --path example/game --quit` was not available by executable name, but the Justfile/.env Godot binary discovery path successfully loaded `example/game` headlessly.
<!-- SECTION:FINAL_SUMMARY:END -->
