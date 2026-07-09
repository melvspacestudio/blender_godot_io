# Repository Guidelines

## Project Context

This is a Godot 4.7+ GLTF pipeline project focused on reliable Blender-to-Godot asset delivery through glTF. It contains a Godot addon for import/linking, modifier-driven scene adjustment, example scenes, showcase assets, and GdUnit4 coverage for core addon behavior.

Treat this repository as addon and asset-pipeline tooling first. Prioritize stable Godot resource serialization, predictable import behavior, clear modifier ownership, and workflows that stay close to Godot editor conventions. Keep runtime examples, addon code, generated/imported metadata, tests, and vendored plugins separated.

## Agent Safety And Permissions

- Stay inside this repository unless the task explicitly names another path.
- Do not read, print, copy, or modify secrets from `.env`, `.envrc`, credentials, tokens, or private local config.
- Use read-only investigation before edits: inspect relevant scripts, scenes, resources, fixtures, tests, and logs first.
- Do not run destructive commands such as `rm -rf`, `git reset --hard`, `git clean -fdx`, force pushes, mass deletes, or broad renames unless the user explicitly requested that exact operation.
- Do not install packages, download assets, change Godot/editor versions, or modify vendored plugins as incidental setup.
- Before broad scene/resource moves, list affected paths and preserve `res://` references, UID sidecars, and import metadata.
- Treat Godot scene/resource diffs as real project state, not disposable churn, until you have inspected why they changed.

## Source Of Truth

- `project.godot` defines the Godot version target, main scene UID, autoloads, enabled plugins, physics backend, rendering settings, and project-wide settings.
- `README.md` describes the intended Blender-to-Godot pipeline, mirrored folder workflow, and generated editable `.tscn` behavior.
- `Justfile` defines supported local commands. It loads `.env`; do not treat a missing exported `GODOT_BIN` in the current shell as a blocker before trying a relevant recipe.
- `addons/godot_gltf_pipeline_addon/plugin.cfg` and `addons/godot_gltf_pipeline_addon/setup/godot_gltf_pipeline.gd` are the addon registration entry points.
- `addons/godot_gltf_pipeline_addon/config/import_config.gd` owns import configuration resources.
- `addons/godot_gltf_pipeline_addon/extension/` owns Godot GLTF document extension behavior.
- `addons/godot_gltf_pipeline_addon/modifiers/` owns modifier implementations and reusable modifier base classes.
- `addons/godot_gltf_pipeline_addon/utility/` owns shared addon helpers.
- `tests/` contains first-party GdUnit4 suites and fixtures.

Do not change project settings, enabled plugins, import formats, scene paths, or resource formats as incidental cleanup. If a durable import, resource, scene, or project setting rule changes, call it out in the final summary.

## Project Structure And Module Organization

- `addons/godot_gltf_pipeline_addon/`: first-party Godot addon code.
- `addons/godot_gltf_pipeline_addon/config/`: import configuration resources.
- `addons/godot_gltf_pipeline_addon/extension/`: `GLTFDocumentExtension` integration.
- `addons/godot_gltf_pipeline_addon/modifiers/base/`: core modifier contracts such as `GGP_NodeModifier`.
- `addons/godot_gltf_pipeline_addon/modifiers/assets/`: material, texture, specular, and asset processor helpers.
- `addons/godot_gltf_pipeline_addon/modifiers/classes/`: class replacement and factory-based node conversion.
- `addons/godot_gltf_pipeline_addon/modifiers/collision/`, `light/`, `mesh/`, `prefab/`, `transform/`, `utility/`: focused modifier families.
- `addons/godot_gltf_pipeline_addon/processors/`: GLTF/node processing utilities.
- `addons/godot_gltf_pipeline_addon/setup/`: editor plugin setup and registration.
- `addons/godot_gltf_pipeline_addon/scenes/`: addon-owned support scenes such as placeholders.
- `addons/godot_gltf_pipeline_addon/utility/`: shared helpers for paths, nodes, meshes, and related addon operations.
- `tests/`: GdUnit4 suites grouped by feature, including `tests/import_config`, `tests/prefab`, `tests/classes`, and `tests/assets`.
- `tests/**/fixtures/`: test-only scenes/resources/data used by suites.
- `assets/models/showcase/`: showcase models and prefabs for examples.
- `scenes/`: example/main scenes for manual verification and demonstration.
- `patches/`: project-maintained third-party patches.
- `reports/`: generated local reports; ignored by git.

Treat `addons/gdUnit4/`, `addons/immediate_gizmos/`, `addons/quick_menu/`, `addons/script-ide/`, and other third-party addons as vendored unless the task explicitly targets them. Keep paths lower `snake_case` where the repo already follows that convention.

## Build, Test, And Development Commands

Use the `Justfile` as the source of truth for common commands.

- `just` lists available recipes.
- `just test` runs all GdUnit4 tests in `res://tests`.
- `just gdunit` runs the same GdUnit4 suite and resolves `GODOT_BIN` from `.env` or available `godot4.7`, `godot4`, or `godot` binaries.

If local setup is missing, create `.env` from `.env.example` and set `GODOT_BIN=/path/to/Godot`. Also create `.envrc` for direnv-compatible shells, for example `GODOT_BIN="/path/to/Godot"`. Prefer locating Godot through Godot Version Manager first, then fall back to a manually installed binary.

When a task needs a direct Godot smoke check that is not covered by the `Justfile`, prefer the configured `$GODOT_BIN` without printing `.env`. Useful direct commands:

- `$GODOT_BIN --headless --path . --quit` performs a headless project load/import smoke check.
- `$GODOT_BIN --headless --editor --path . --quit` performs an editor/plugin parse and load check for `@tool` scripts.
- `"$GODOT_BIN" --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests --ignoreHeadlessMode -c` runs the GdUnit test suite directly when `just gdunit` is not suitable.

Only diagnose PATH or binary lookup after the relevant recipe fails.

## Engineering Standards

- Follow existing GDScript style: tabs for indentation, `@tool` where editor execution is required, and typed variables where practical.
- Use `class_name` for reusable addon classes and keep exported project classes under the existing `GGP_` prefix.
- Keep modules small and cohesive. Prefer explicit Godot-native scripts, resources, scenes, exported properties, and signals over broad managers or custom tooling.
- Keep import extension code in `extension/`, modifier behavior in the relevant `modifiers/` family, setup/registration code in `setup/`, and shared helpers in `utility/`.
- Prefer strictly typed objects/resources over `Dictionary` DTOs when the data has a stable contract. Use `Dictionary` for true key/value maps, sparse dynamic data, or Godot APIs that require it.
- Avoid preloading script classes just to access types. Prefer `class_name` registration for reusable addon classes, and reserve `preload()` for assets or intentionally local/private scripts.
- Add doc comments for public classes, methods, signals, and exported properties when contracts, units, ownership, or editor/import behavior are not obvious from names and types.
- Make path handling explicit. Preserve `res://` semantics, imported asset locations, generated editable `.tscn` expectations, and mirrored source/export folder assumptions.
- Validate data at project boundaries before trusting imported GLTF data, custom import config resources, user-authored fixtures, or asset metadata. Once a local invariant is established, keep later code simple.
- For generated/imported assets, do not rewrite metadata solely for formatting or cleanup.
- Do not manually edit `.gd.uid`, `.import`, or generated Godot metadata unless the task explicitly requires metadata repair.

## Design Principles: SOLID, DRY, KISS

Use SOLID, DRY, and KISS as lightweight guardrails for Godot-native addon work, not as a reason to add speculative architecture.

- Single Responsibility: each script, resource, modifier, factory, and support scene should have one clear reason to change. Avoid mixing import parsing, node mutation, asset processing, editor registration, and test fixture setup in one script unless the existing code already owns that coordination.
- Open/Closed: extend behavior through resources, exported properties, scene composition, small focused modifiers, factories, or Godot extension hooks before editing stable shared code. Do not add speculative extension points.
- Liskov Substitution: derived modifiers, factories, and reusable `class_name` types must preserve base lifecycle behavior, exported properties, signals, return contracts, and public method expectations.
- Interface Segregation: prefer small focused APIs, resource contracts, and helper methods. Do not force unrelated modifier families to depend on broad utility objects or god classes.
- Dependency Inversion: high-level import behavior should depend on stable project-owned contracts, resources, modifier APIs, and Godot extension points instead of fragile scene paths or concrete child hierarchies. Keep this simple and Godot-native.
- DRY: avoid duplicating import config keys, resource paths, node-path strings, modifier lookup logic, class replacement rules, and asset processing formulas. Reuse existing addon scripts, resources, tests, fixtures, and exported tuning values before creating new ones.
- KISS: prefer the smallest Godot-native change that solves the task. Avoid new autoloads, plugins, global state, code generators, import frameworks, speculative flags, and broad helper layers unless the task clearly requires them.
- Prefer clear local code over premature generalization. Do not remove useful duplication if sharing it would create a confusing abstraction.

## Godot Asset Workflow

After adding or renaming `.gd` scripts, changing `class_name`, or creating Godot resources outside the editor, regenerate or validate UIDs through the project workflow. Use the Godot editor or a headless project/editor load as appropriate so Godot can generate and validate metadata.

Commit legitimate `.gd.uid`, `.import`, `.tscn`, `.tres`, `project.godot`, and other Godot metadata changes only when they are direct outputs of the task. If a UID sidecar or resource header changes, inspect `git status --short` and keep only changes that belong to the task.

For assets, keep showcase/source media under `assets/` unless the task explicitly moves them. Do not move third-party packs, showcase models, or material libraries as incidental cleanup; broken `res://` paths are costly in Godot.

## Task Workflow And Context

Use the lightest workflow that protects correctness. Documentation-only edits and narrow mechanical changes need local file inspection. Import behavior, modifier logic, scene/resource changes, or fixture updates require reading the relevant script, scene, resource, and tests before editing.

For bug fixes, first identify the likely root cause from local code, scene wiring, resources, logs, fixtures, or a focused reproduction. If confidence is low, add temporary diagnostics or create a minimal fixture before changing import behavior.

Prefer `rg`/`rg --files`, narrow file reads, and the smallest relevant source, test, scene, resource, or documentation context that explains the behavior.

For visible scene/resource changes, inspect the affected `.tscn` or `.tres` files and preserve related generated metadata. Godot scene/resource diffs are legitimate project state, not suspicious churn by default.

For non-trivial code changes, briefly check that the solution stays simple, avoids unnecessary duplication, keeps script/resource responsibilities clear, and records durable decisions in project docs only when the task explicitly calls for documentation.

## Verification Matrix

GdUnit4 is installed under `addons/gdUnit4/`, and first-party suites live under `tests/`. For code or scene changes, run the relevant GdUnit suites plus a headless project load when Godot is available. Documentation-only changes do not require runtime tests.

- Documentation-only changes: no runtime tests required; say tests were not run.
- GDScript-only addon changes: run the focused GdUnit suite when practical, or `just test` for full coverage.
- Import config, modifier, prefab, class, or asset processor changes: run `just test`.
- Scene, resource, UI, import, or asset-path changes: run `just test` when behavior is covered, then `$GODOT_BIN --headless --path . --quit` to catch serialization/import issues.
- Editor plugin setup, `@tool` scripts, or `addons/godot_gltf_pipeline_addon/setup/**` changes: run `$GODOT_BIN --headless --editor --path . --quit` when Godot is available.
- `project.godot`, enabled plugins, autoloads, main scene, physics, rendering, or import settings changes: call out the durable project-level impact in the final summary.
- Visual/editor-facing changes: include a screenshot or concise manual verification note when possible.

## Commit, PR, And Repo Hygiene

Use Conventional Commits as shown in history and current guidance: `feat(showcase): ...`, `fix(import-config): ...`, `chore: ...`, `test(gdunit): ...`. Keep commits scoped and imperative.

Pull requests should describe import/tooling impact, list tests run, link related issues when available, and include screenshots only for visible editor or scene changes.

Keep `.env`, `.envrc`, `.godot/`, `reports/`, logs, exports, platform builds, and temporary files uncommitted. Keep generated or baked artifacts out of commits unless the task explicitly requires committed Godot resources.

Treat Godot content and configuration files, including `.tscn`, `.tres`, `.res`, `project.godot`, import metadata, and editor/project settings, as legitimate project state. Do not restore or revert them just because they changed during a Godot/editor/test run. Only separate or revert those files when they are clearly unrelated to the current task, you did not touch the relevant scene/resource/settings domain, and you can explain why the change is disposable.

Check `git status --short` before finishing and mention unrelated pre-existing changes in the final response.

## Final Response Checklist

When finishing a task, report:

- Files changed and why.
- Tests/checks run, or why they were not run.
- Any Godot-generated `.uid`, `.import`, `.tscn`, `.tres`, or `project.godot` changes.
- Any durable import, asset, scene, resource, plugin, or project-setting rule change.
- Any unrelated pre-existing worktree changes noticed.
