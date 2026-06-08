---
id: GP-2.2
title: Harden texture and material asset extraction processors
status: Done
assignee:
  - Codex
created_date: '2026-06-08 15:34'
updated_date: '2026-06-08 17:54'
labels:
  - audit
  - godot
  - assets
dependencies: []
references:
  - godot/godot_gltf_pipeline_addon/modifiers/assets/texture_processor.gd
  - godot/godot_gltf_pipeline_addon/modifiers/assets/material_processor.gd
  - godot/godot_gltf_pipeline_addon/modifiers/assets/specular_processor.gd
  - example/game/examples/2_materials/import_config.tres
  - example/game/examples/5_full/import_config.tres
modified_files:
  - godot/godot_gltf_pipeline_addon/modifiers/assets/asset_processor_utility.gd
  - >-
    godot/godot_gltf_pipeline_addon/modifiers/assets/asset_processor_utility.gd.uid
  - godot/godot_gltf_pipeline_addon/modifiers/assets/texture_processor.gd
  - godot/godot_gltf_pipeline_addon/modifiers/assets/material_processor.gd
  - godot/godot_gltf_pipeline_addon/modifiers/assets/specular_processor.gd
  - example/game/tests/assets/asset_processors_test.gd
  - example/game/tests/assets/asset_processors_test.gd.uid
parent_task_id: GP-2
priority: high
ordinal: 4000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Harden the texture, material, and specular asset processors so malformed or unusual glTF metadata cannot crash import or write outside the configured output folders.

Current behavior:
- `GGP_Texture_NodeModifier` writes PNG files from `state.get_images()` using `state.json["images"][i]["name"]` without checking whether `images` exists, whether index `i` exists, whether `name` is valid, or whether the target directory exists.
- `GGP_Material_NodeModifier` writes `.tres` files from `state.get_materials()` using `state.json.get("materials", [])[i]["name"]` with the same unchecked index/name assumptions.
- `GGP_Specular_NodeModifier` also indexes `state.json.get("materials", [])[i]` and prints specular color information during normal import.

Decisions for this task:
- Processors must create configured output directories recursively before saving assets. If directory creation fails, `push_warning()` and skip that processor without crashing the import.
- Existing extracted assets are preserved by default. Add an explicit exported overwrite flag to the texture and material processors, defaulting to `false`; only overwrite existing `.png` / `.tres` assets when the flag is enabled.
- Names read from glTF JSON must be converted to safe filename stems that cannot escape the configured output directory. The sanitizer should allow only ASCII letters, ASCII digits, `_`, and `-` in output stems. All other characters, including path separators, dots, whitespace, and path-like input such as `..`, are normalized to `_`; repeated `_` runs are collapsed; leading/trailing `_` is trimmed; empty sanitized names fall back to deterministic generated names such as `image_%d` and `material_%d`.
- Do not suffix duplicate sanitized names. Duplicate image/material names are treated as intentional sharing of the same output texture/material path.
- With overwrite disabled, the first existing or successfully written asset for a reused duplicate path wins; later duplicate entries reuse the same path without saving.
- With overwrite enabled, every duplicate entry attempts to save to the same reused path in runtime order; later successful duplicate writes overwrite earlier ones, so the last successful duplicate wins.
- Missing JSON arrays, missing `name` fields, or runtime arrays longer than their corresponding JSON arrays must not crash import. Warn with context and use deterministic fallback names for affected entries.
- If saving a specific image/material fails, warn and skip only that asset. Do not set `take_over_path()` or `material_path` metadata for a failed save.
- Include `GGP_Specular_NodeModifier` in this hardening task: handle missing/mismatched material JSON entries safely and remove normal-path `print()` output in favor of no log or concise warning only when data is malformed.
- Add focused GdUnit tests for name sanitization, fallback names, duplicate-name path reuse, overwrite flag behavior, and JSON/runtime mismatch handling.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Texture and material processors create configured output directories recursively before saving; if directory creation fails, they `push_warning()` and skip without crashing import.
- [x] #2 Texture and material processors preserve existing generated assets by default and expose an explicit exported overwrite flag, defaulting to `false`, that allows intentional regeneration.
- [x] #3 Image and material names from glTF JSON are sanitized into safe filename stems that cannot escape the configured output directory: allowed output characters are ASCII letters, ASCII digits, `_`, and `-`; all other characters are normalized to `_`; repeated `_` runs are collapsed; leading/trailing `_` is trimmed; empty or missing names use deterministic fallback names.
- [x] #4 Path separators, dots, whitespace, `..`, and other path-like or invalid input cannot affect output directories or file extensions; they are normalized into safe stems before `.png` or `.tres` is appended by the processor.
- [x] #5 Duplicate sanitized image/material names intentionally reuse the same output path and are not auto-suffixed; this behavior is documented in code comments or repository docs.
- [x] #6 With overwrite disabled, the first existing or successfully written asset for a duplicate output path wins and later duplicate entries reuse that path without saving.
- [x] #7 With overwrite enabled, every duplicate entry attempts to save to the reused output path in runtime order, so later successful duplicate writes overwrite earlier ones.
- [x] #8 Missing `images` / `materials` arrays, missing `name` fields, and JSON/runtime array length mismatches are handled explicitly with contextual warnings and fallback names where needed.
- [x] #9 A failed save for one image/material warns and skips only that asset; it does not crash the import and does not assign a path/meta value for the failed asset.
- [x] #10 `GGP_Specular_NodeModifier` handles missing or mismatched material JSON entries without crashing and no longer prints normal-path specular color messages during import.
- [x] #11 Focused GdUnit tests cover sanitization, fallback naming, duplicate-name path reuse, overwrite flag behavior including duplicate writes, and JSON/runtime mismatch handling.
- [x] #12 Affected material and texture sample imports are revalidated in the Godot example project when Godot is available; if unavailable, completion notes record the exact missing executable or failure.
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
# GP-2.2 Implementation Plan

- Harden `GGP_Texture_NodeModifier`, `GGP_Material_NodeModifier`, and `GGP_Specular_NodeModifier` per the accepted plan: recursive output directory creation, safe filename stems, no default overwrite, duplicate path reuse, safe JSON/runtime mismatch handling, and no normal-path specular prints.
- Keep texture/material overwrite behavior explicit via exported `overwrite_existing: bool = false` fields.
- Add focused GdUnit tests under `example/game/tests/assets/` covering sanitizer behavior, fallback naming, duplicate path reuse, overwrite behavior, JSON/runtime mismatch handling, and specular mismatch safety.
- Validate with `git diff --check`, targeted `rg` checks, and Godot/GdUnit runtime checks if a local `godot`, `godot4`, or `godot4.7` executable is available; otherwise record the unavailable executable names.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Task grooming decisions recorded from user input on 2026-06-08: create missing directories; preserve existing extracted assets by default; add an explicit overwrite flag; sanitize names; duplicate sanitized names should reuse the same texture/material path rather than suffixing; skip failed individual saves with warnings; include specular processor hardening; include focused GdUnit tests. Filename sanitizer rules: output stems allow ASCII letters, ASCII digits, `_`, and `-`; all other characters including path separators, dots, whitespace, and path-like input such as `..` become `_`; collapse repeated `_`; trim leading/trailing `_`; use deterministic fallbacks such as `image_%d` and `material_%d` when empty. Duplicate behavior: with overwrite disabled, first existing or successfully written asset wins and later duplicates reuse the path without saving; with overwrite enabled, every duplicate entry attempts to write to the same path in runtime order, so the last successful duplicate wins. Explanation for JSON/runtime mismatch: Godot exposes runtime image/material arrays (`state.get_images()`, `state.get_materials()`) separately from raw `state.json`; malformed, generated, stripped, or importer-transformed glTF data can make JSON arrays missing, shorter, or missing `name`, so processors must avoid blind `json[i]` indexing.

Confirmed during grooming: JSON/runtime array mismatch handling must be safe. Processors must not crash on missing `images` / `materials`, missing `name`, or array length mismatch; they should warn with enough context and continue with deterministic fallback names where possible.

Implemented GP-2.2 using a shared `GGP_AssetProcessor_Utility` for output directory resolution/creation, safe filename stem sanitization, resource-existence checks, and defensive glTF JSON access. Texture/material processors now default to preserving existing extracted assets and expose `overwrite_existing: bool = false`. Specular processing now safely skips malformed/missing material JSON and no longer prints normal-path specular color messages.

Validation completed with Godot `/home/melvspace/.local/share/godot/app_userdata/Godot Version Manager/versions/Godot_v4.7-beta5_linux.x86_64` (4.7-beta5): `godot --headless --path example/game --quit`, `godot --headless --path example/game --editor --quit`, GdUnit asset suite `res://tests/assets/asset_processors_test.gd` (9/9), and existing GdUnit import config suite `res://tests/import_config/import_config_test.gd` (3/3). Static checks: `git diff --check` passed; `rg "print\(" godot/godot_gltf_pipeline_addon/modifiers/assets/specular_processor.gd` returned no matches. GdUnit runner emits a known remote debugger port 0 error before running, but exits 0 and reports all tests passing.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Implemented hardened asset extraction for texture, material, and specular processors. Texture/material extraction now creates configured output directories recursively, sanitizes glTF names to safe filename stems with deterministic fallbacks, preserves existing files by default, supports explicit overwrite, reuses duplicate sanitized paths, and skips failed individual saves without assigning path metadata. Specular processing now handles missing/malformed material JSON safely and no longer prints normal-path specular color data.

Added focused GdUnit coverage under `example/game/tests/assets/` for sanitizer rules, fallback naming, duplicate path reuse, overwrite behavior, failed directory creation, JSON/runtime mismatch handling, and specular mismatch safety. Validation passed with Godot 4.7-beta5 using headless project/editor loads, the new asset suite, the existing import-config suite, `git diff --check`, and the targeted no-`print()` search.
<!-- SECTION:FINAL_SUMMARY:END -->
