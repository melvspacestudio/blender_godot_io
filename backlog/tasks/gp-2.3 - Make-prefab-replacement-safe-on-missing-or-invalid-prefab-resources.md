---
id: GP-2.3
title: Make prefab replacement safe on missing or invalid prefab resources
status: Done
assignee:
  - Codex
created_date: '2026-06-08 15:34'
updated_date: '2026-06-08 19:28'
labels:
  - audit
  - godot
  - prefabs
dependencies: []
references:
  - godot/godot_gltf_pipeline_addon/modifiers/prefab/prefab_modifier.gd
  - godot/godot_gltf_pipeline_addon/utility/node_utility.gd
  - example/game/examples/4_prefabs/import_config.tres
  - example/game/examples/5_full/import_config.tres
  - godot/godot_gltf_pipeline_addon/scenes
modified_files:
  - godot/godot_gltf_pipeline_addon/modifiers/prefab/prefab_modifier.gd
  - godot/godot_gltf_pipeline_addon/utility/node_utility.gd
  - godot/godot_gltf_pipeline_addon/scenes/prefab_error_placeholder.tscn
  - example/game/tests/prefab/prefab_modifier_test.gd
parent_task_id: GP-2
priority: high
ordinal: 5000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Make prefab replacement robust while preserving current intended behavior.

Current behavior:
- A node whose normalized name starts with `$` is treated as a prefab marker.
- The prefab base path is resolved from `prefab_dir` and the marker name without `$`.
- Candidate resources are checked using the exported `extensions` array, in array order.
- For a normal marker, the loaded `PackedScene` is instantiated and returned so the GLTF extension replaces the marker.
- For `extras.geometry_nodes == true`, each child of the marker is replaced with a fresh prefab instance while the marker node remains.

Problem: missing, invalid, or non-instantiable prefab resources can currently call `instantiate()` on null or otherwise break import. The task should keep the existing replacement semantics and add robust fallback behavior.

Decisions for this task:
- Preserve the existing exported `extensions` array as the authority for candidate resolution order. This means users can prioritize `.tscn`, `.scn`, `.glb`, `.gltf`, or any custom order by editing the modifier resource; the implementation should validate/skip empty extension entries but not reorder them.
- If a matching candidate path exists but does not load as `PackedScene`, keep checking later extensions in the configured order.
- Create one reusable prefab error placeholder scene at `godot/godot_gltf_pipeline_addon/scenes/prefab_error_placeholder.tscn`, and instantiate that scene for prefab fallback cases instead of constructing one-off placeholder contents inline for every failure.
- If no valid `PackedScene` can be found, replace the failed prefab target with an instance of the reusable visible bright red error placeholder scene instead of crashing or silently leaving an unresolved marker.
- The instantiated error placeholder should make the broken prefab obvious in the imported scene and carry enough context in name/meta or child label-equivalent data for debugging: marker name, resolved base path, attempted candidate paths, and failure reason.
- For a normal `$Foo` marker, successful prefab instantiation should preserve current behavior: replace the marker and preserve marker name, owner, transform, and extras metadata via the existing replacement flow.
- For prefab fallback on a normal `$Foo` marker, the instantiated error placeholder replaces the marker and inherits the marker node's position, rotation, and scale.
- For `extras.geometry_nodes == true`, preserve current behavior: keep the marker parent and replace each child with a fresh prefab instance. Remove any double-free behavior if `GGP_NodeUtility.replace()` already queues the original child for freeing.
- For prefab fallback under `extras.geometry_nodes == true`, each failed child replacement uses a fresh instance of the reusable error placeholder and inherits that child marker node's position, rotation, and scale.
- Do not transfer marker children into a normal prefab replacement. Keep current `skip_children = true` behavior; use `geometry_nodes` for per-child replacement.
- If `PackedScene.instantiate()` fails or does not produce a `Node`, fall back to the same reusable visible red error placeholder behavior.
- Add focused GdUnit tests for missing prefab fallback, invalid candidate fallback after checking later extensions, successful normal replacement, successful `geometry_nodes` replacement, and instantiation failure fallback where practical.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Successful normal `$PrefabName` replacement preserves current behavior: the prefab instance replaces the marker and keeps expected marker name, owner, transform, and extras metadata.
- [x] #2 Successful `extras.geometry_nodes == true` replacement preserves current behavior: the marker parent remains and each child is replaced by a fresh prefab instance.
- [x] #3 The exported `extensions` array remains the candidate resolution order; empty/invalid extension entries are skipped without reordering valid entries.
- [x] #4 If a candidate path exists but does not load as `PackedScene`, later extensions are still checked before falling back.
- [x] #5 Missing prefabs, invalid candidate resources, and failed/non-Node instantiation never call methods on null and do not abort the whole import.
- [x] #6 A reusable visible bright red prefab error placeholder scene is created at `godot/godot_gltf_pipeline_addon/scenes/prefab_error_placeholder.tscn`, and prefab fallback code instantiates that scene for missing prefabs, invalid candidate resources after all candidates are checked, and instantiation failures.
- [x] #7 For normal marker fallback, the instantiated error placeholder replaces the marker and inherits the marker node's position, rotation, and scale.
- [x] #8 For `geometry_nodes` fallback, each failed child replacement gets a fresh instantiated error placeholder that inherits the failed child node's position, rotation, and scale while the marker parent remains.
- [x] #9 The error placeholder records debugging context such as marker name, resolved base path, attempted candidate paths, and failure reason in a discoverable way.
- [x] #10 Normal prefab replacement does not transfer marker children into the prefab instance; current `skip_children = true` behavior remains intentional.
- [x] #11 `geometry_nodes` replacement avoids double-freeing original children when using `GGP_NodeUtility.replace()`.
- [x] #12 Focused GdUnit tests cover missing prefab fallback, invalid candidate fallback after later-extension checks, successful normal replacement, successful `geometry_nodes` replacement, and instantiation failure fallback where practical.
- [x] #13 Godot import validation covers at least one successful prefab replacement and one missing-prefab/error-placeholder scenario when Godot is available; if unavailable, completion notes record the exact missing executable or failure.
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Resolve prefab candidates in the configured extension order while skipping invalid extension entries.
2. Instantiate valid PackedScene resources for normal markers and geometry_nodes children while preserving existing replacement semantics.
3. Fall back to a reusable visible prefab error placeholder scene for missing, invalid, or non-Node instantiation cases and attach debugging context.
4. Tighten node replacement to preserve sibling index, owner, transform, name, and extras without duplicate-name suffixes or double frees.
5. Add focused GdUnit coverage for successful replacements and fallback paths, then validate through the Justfile GdUnit entry point.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Task grooming decisions recorded from user input on 2026-06-08: prefer current prefab behavior and make it robust. Missing prefab, invalid prefab after checking later extensions, and instantiate failure should fall back to a visible bright red error placeholder node. The placeholder should be implemented as one reusable error scene at `godot/godot_gltf_pipeline_addon/scenes/prefab_error_placeholder.tscn` and fallback code should instantiate that scene. Error placeholder instances inherit position, rotation, and scale from the marker node they replace; under `geometry_nodes`, each failed child replacement gets its own placeholder inheriting that child node's position, rotation, and scale. Existing extension order remains authoritative; explanation: the exported `extensions` array is the user's configured priority order for candidate resources, so robust code should validate entries and continue through them without changing order. Normal replacement should keep current semantics. `geometry_nodes` should keep current semantics. Normal replacement should not transfer children. Add focused GdUnit tests.

Fixed failing prefab tests by updating `GGP_NodeUtility.replace()` to remove the original node from its parent before adding the replacement, preserving sibling index, owner, transform, name, and extras while avoiding Godot's automatic duplicate-name suffixes (`$TestPrefab2`, `ChildA2`, etc.). Also cleaned up the standalone placeholder instance in the empty PackedScene fallback test so GdUnit reports 0 orphans.

Validation on 2026-06-08: `just gdunit` passed with 18 test cases, 0 errors, 0 failures, 0 skipped, and 0 orphans. Godot printed renderer/resource shutdown leak diagnostics after the GdUnit success summary, but the test command exited 0 and reported `Run tests ends with 0`.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Implemented robust prefab replacement fallback behavior while preserving existing successful replacement semantics. Prefab resolution now validates configured extensions in order, continues past invalid resources, and uses a reusable visible red error placeholder scene when a prefab is missing, invalid, or cannot instantiate to a Node. Error placeholders inherit the failed target transform and carry debugging context for marker name, resolved base path, attempted candidates, invalid candidates, skipped extensions, and failure reason.

Updated node replacement so replacements preserve sibling position, owner, transform, name, and extras metadata without Godot duplicate-name suffixes, and without double-freeing geometry_nodes children. Added focused GdUnit prefab tests and fixtures covering normal replacement, geometry_nodes replacement, extension fallback order, missing prefab fallback, geometry_nodes fallback, and empty PackedScene fallback.

Validation: `just gdunit` passed with 18 test cases, 0 errors, 0 failures, 0 skipped, and 0 orphans. Godot emitted renderer/resource shutdown leak diagnostics after the successful GdUnit summary, but the command exited 0.
<!-- SECTION:FINAL_SUMMARY:END -->
