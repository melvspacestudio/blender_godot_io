# Repository Guidelines

## Project Overview

This repository contains Godot - GLTF Pipeline tooling. The current codebase is centered on a Godot 4 editor add-on that extends glTF import behavior and an example Godot project used to exercise the pipeline.

Keep changes scoped to the toolchain:

- `godot/godot_gltf_pipeline_addon/` is the source Godot add-on.
- `example/game/` is the Godot example project and integration fixture.
- `example/game/assets/`, `example/game/examples/`, and `example/game/blender/` contain sample assets and generated/imported outputs.
- `pr/` contains presentation assets such as the project logo.
- `backlog/` is managed through Backlog.md MCP tools. Do not edit backlog task files directly.

## Backlog Workflow

This project uses Backlog.md MCP for task tracking. Read the workflow overview before deciding whether work needs a task. For small mechanical edits, make the change directly. For work that requires planning, design decisions, investigation, or multi-step implementation, search Backlog first and create or update tasks through the MCP tools.

Do not manually edit Backlog markdown files. Use the Backlog MCP tools so metadata and relationships stay consistent.

<!-- BACKLOG.MD MCP GUIDELINES START -->

<CRITICAL_INSTRUCTION>

## BACKLOG WORKFLOW INSTRUCTIONS

This project uses Backlog.md MCP for all task and project management activities.

**CRITICAL GUIDANCE**

- If your client supports MCP resources, read `backlog://workflow/overview` to understand when and how to use Backlog for this project.
- If your client only supports tools or the above request fails, call `backlog.get_backlog_instructions()` to load the tool-oriented overview. Use the `instruction` selector when you need `task-creation`, `task-execution`, or `task-finalization`.

- **First time working here?** Read the overview resource IMMEDIATELY to learn the workflow
- **Already familiar?** You should have the overview cached ("## Backlog.md Overview (MCP)")
- **When to read it**: BEFORE creating tasks, or when you're unsure whether to track work

These guides cover:
- Decision framework for when to create tasks
- Search-first workflow to avoid duplicates
- Links to detailed guides for task creation, execution, and finalization
- MCP tools reference

You MUST read the overview resource to understand the complete workflow. The information is NOT summarized here.

</CRITICAL_INSTRUCTION>

<!-- BACKLOG.MD MCP GUIDELINES END -->

## Development Environment

Use Godot 4 for editor and import-pipeline validation. The example project currently declares Godot `4.7` features in `example/game/project.godot`; if your local Godot version differs, avoid committing editor-driven churn unless it is intentional.

Useful checks when the `godot` executable is available:

```sh
godot --headless --path example/game --quit
godot --headless --path example/game --editor --quit
```

The repository `Justfile` provides the preferred GdUnit test entry point:

```sh
just gdunit
```

It loads `.env` automatically and respects `GODOT_BIN`; if `GODOT_BIN` is unset, the recipe searches for `godot4.7`, `godot4`, then `godot` on `PATH`.

If Godot is not installed or the executable has a different name, state that verification was not run instead of inventing a passing result.

## GDScript Conventions

- Use tabs for GDScript indentation, matching the existing files.
- Keep editor/import scripts annotated with `@tool` when they must run in the editor.
- Use typed variables, typed arrays, and return types where practical, following the existing add-on style.
- Prefer Godot APIs such as `ResourceLoader`, `ResourceSaver`, `ProjectSettings`, `path_join`, and `uid://` references over ad hoc path handling.
- Keep reusable import behavior in `GGP_NodeModifier` subclasses under `godot/godot_gltf_pipeline_addon/modifiers/`.
- Modifier hooks follow the lifecycle in `GGP_NodeModifier`: `pre_generate`, `generate_node`, `process_node`, then `process_scene`.
- Avoid broad refactors while changing import modifiers. The add-on order and one-modifier-per-global-script de-duplication behavior are part of the import flow.

## Godot Asset And Metadata Rules

- Treat `.import`, `.uid`, `.tres`, and `.tscn` files as Godot-owned metadata unless the task explicitly targets them.
- Do not edit `.godot/`; it is ignored local editor state.
- Do not overwrite generated `.tscn` asset customization scenes unless the task is specifically about regeneration behavior. The README states generated scenes are intended to remain manually editable.
- Keep binary assets such as `.blend`, `.glb`, `.png`, `.ogg`, and `.wav` unchanged unless the request is asset-related.
- Before committing editor-driven changes, review `git diff` carefully. Godot can rewrite resource IDs, import settings, and project metadata as side effects.

## Example Project Notes

The example project enables the source add-on as `res://addons/godot_gltf_pipeline_addon/plugin.cfg`. In this repository, `example/game/addons/godot_gltf_pipeline_addon` is a symlink to `godot/godot_gltf_pipeline_addon`; preserve that relationship when moving or reorganizing add-on files.

Import configuration resources, such as `example/game/global_import_config.tres` and per-example `import_config.tres` files, drive which modifiers run for imported glTF assets. Prefer adding focused resources or modifiers instead of hardcoding example-specific behavior in the extension.

## Verification Expectations

Choose validation based on the change:

- Documentation-only changes: no runtime test is required.
- GDScript logic changes: run a Godot headless load of `example/game` if available.
- GDScript test changes: run `just gdunit` when the `Justfile`, GdUnit add-on, and Godot executable are available.
- Import pipeline changes: reimport the affected sample asset in Godot, then review the changed `.import`, `.uid`, `.tres`, `.tscn`, and generated asset files.
- Scene or resource edits: open or load the example project and check for missing script/resource errors.

Always report what was actually run and any tools that were unavailable.
