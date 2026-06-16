---
id: GP-4
title: Document socket node modifier feature proposal
status: Done
assignee:
  - Codex
created_date: '2026-06-16 10:09'
updated_date: '2026-06-16 10:23'
labels:
  - documentation
  - proposal
  - node-modifiers
dependencies: []
documentation:
  - >-
    https://dev.epicgames.com/documentation/unreal-engine/using-sockets-with-static-meshes-in-unreal-engine
modified_files:
  - >-
    backlog/docs/proposals/socket-node-modifier/doc-1 -
    Socket-Node-Modifier-Feature-Proposal.md
  - backlog/tasks/gp-4 - Document-socket-node-modifier-feature-proposal.md
priority: medium
ordinal: 11000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Write a feature proposal for adding Unreal-style static mesh sockets to the Godot glTF pipeline add-on through node modifiers. The proposal should ground the feature in the current import modifier lifecycle and describe authoring conventions, generated Godot scene structure, import behavior, edge cases, and validation expectations.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 A documentation page describes the socket feature goal and user-facing workflow for attaching gameplay nodes to imported meshes.
- [x] #2 The proposal explains how the feature can fit into existing node modifiers and the glTF import lifecycle without hardcoding example-specific behavior.
- [x] #3 The proposal covers naming or metadata conventions, generated Godot node output, modifier configuration, reimport behavior, and validation/testing expectations.
- [x] #4 The proposal references the Unreal static mesh sockets concept as external inspiration without copying Unreal-specific implementation details.
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Create a Backlog-managed documentation page under `backlog/docs/proposals/` for the socket node modifier proposal, rather than editing generated Godot metadata or asset files.
2. Ground the proposal in the current import flow: `GGP_NodeModifier` hooks, `GGP_GLTF_Extension` modifier execution, `GGP_ImportConfig` resource configuration, and existing extras/name-marker conventions used by class, prefab, collision, discard, and transform modifiers.
3. Describe the user-facing feature as named mesh-local attachment points inspired by Unreal static mesh sockets: sockets are authorable in Blender/glTF, become stable Godot `Node3D` markers, and can host child gameplay scenes or runtime lookup points.
4. Propose implementation details without writing code in this task: metadata and naming conventions, generated node output, optional prefab instantiation behavior, reimport preservation rules, modifier ordering, edge cases, and validation expectations.
5. Update GP-4 with the created documentation path and mark acceptance criteria complete after reviewing the resulting proposal.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Created Backlog document doc-1 at `backlog/docs/proposals/socket-node-modifier/doc-1 - Socket-Node-Modifier-Feature-Proposal.md`. The proposal uses Unreal static mesh sockets as conceptual reference, maps the feature onto `GGP_NodeModifier` hooks, and keeps implementation scoped to configurable modifier behavior rather than example-specific logic.

Reviewed the document after creation and corrected the sample configuration so it does not redeclare the inherited `enabled` flag from `GGP_NodeModifier`. Documentation-only change; no Godot runtime checks were run.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Added a Backlog-managed feature proposal for a future `GGP_SocketNodeModifier`. The document describes artist workflow, Blender/glTF metadata and naming conventions, expected Godot `Marker3D`/`Node3D` output, modifier hook placement, optional attachment-scene behavior, reimport/customization constraints, ordering with existing modifiers, edge cases, runtime usage, and validation expectations.

Validation: reviewed the generated document and checked the worktree. No runtime Godot or GdUnit checks were run because this task only creates documentation.
<!-- SECTION:FINAL_SUMMARY:END -->
