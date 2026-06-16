---
id: doc-1
title: Socket Node Modifier Feature Proposal
type: specification
created_date: '2026-06-16 10:15'
updated_date: '2026-06-16 10:22'
tags:
  - proposal
  - godot
  - gltf
  - node-modifiers
  - sockets
---
# Socket Node Modifier Feature Proposal

## Status

Proposed.

## Summary

Add a socket node modifier to the Godot glTF pipeline add-on. A socket is a named, mesh-local attachment point that survives import and reimport as a stable Godot scene node. Artists place sockets in Blender near the relevant mesh or asset root; the importer converts those authored markers into Godot `Marker3D` or `Node3D` children that gameplay code and manually edited asset customization scenes can use for attachments such as muzzle flashes, handles, doors, VFX, audio emitters, and interaction prompts.

The feature is inspired by Unreal Engine static mesh sockets: Unreal stores named attachment points on a static mesh, exposes their relative transform, and lets placed objects attach to them in the level. The Godot pipeline should adopt the useful concept, not Unreal's editor-specific implementation. In this repository, sockets should be implemented as normal node modifiers so they compose with existing import configuration, naming conventions, and generated `.tscn` customization scenes.

Reference: https://dev.epicgames.com/documentation/unreal-engine/using-sockets-with-static-meshes-in-unreal-engine

## Goals

- Provide stable, named attachment points for imported static glTF assets.
- Let artists author socket positions in Blender without requiring manual placement after every import.
- Represent sockets as ordinary Godot nodes so they are visible, editable, scriptable, and compatible with scene inheritance/customization.
- Keep behavior configurable through `GGP_ImportConfig` and `GGP_NodeModifier` resources.
- Preserve the existing rule that generated `.tscn` customization scenes are not overwritten after first generation.
- Avoid hardcoded example-specific behavior.

## Non-Goals

- Do not add a custom Godot editor socket manager in the first implementation.
- Do not implement skeletal bone sockets yet. Bone/socket attachment can be a later feature once static mesh sockets are stable.
- Do not require every socket to instantiate a scene. A socket marker is useful on its own.
- Do not replace the existing prefab marker workflow; socket attachments should compose with it.

## Current Pipeline Fit

The add-on already exposes a modifier lifecycle through `GGP_NodeModifier`:

- `pre_generate(state)` can inspect or normalize the `GLTFState` before Godot nodes are generated.
- `generate_node(state, gltf_node, scene_parent, node)` can create or substitute the node for a glTF node.
- `process_node(state, gltf_node, json, node)` can modify or replace the generated Godot node.
- `process_scene(state, root)` can finalize the whole imported tree.

`GGP_GLTF_Extension` runs configured modifiers from nearest import config to parent configs, with one run per global script name per lifecycle hook. That means a socket modifier should be self-contained, deterministic, and safe to configure at either project or folder scope.

Existing modifier conventions are useful precedents:

- `GGP_ClassNodeModifier` reads `extras.class_name` and can generate typed Godot nodes.
- `GGP_PrefabModifier` uses `$Name` marker nodes to replace imported markers with external scenes.
- `GGP_CollissionNodeModifier` reads extras such as `convex` from glTF nodes.
- `GGP_NormalizeTransformNodeModifier` already treats `_Root` and `_Origin` as transform-authoring markers.
- `GGP_DiscardNodeModifier` removes nodes with a name suffix convention.

Sockets should follow this pattern: detect authored intent through extras and/or a narrow naming convention, then transform those marker nodes into explicit Godot attachment nodes.

## Proposed User Workflow

1. In Blender, create an Empty at the desired attachment point.
2. Parent the Empty to the mesh or asset-local node whose transform should drive the socket.
3. Mark it as a socket using either metadata or name convention:
   - Preferred metadata: custom property `ggp_socket = "Muzzle"`.
   - Name fallback: `@socket/Muzzle` or `Socket_Muzzle`, configurable by the modifier.
4. Optionally add socket metadata:
   - `ggp_socket_group = "weapon"` for filtering or organization.
   - `ggp_socket_attach = "res://path/to/attachment.tscn"` for an optional first-pass attachment scene.
   - `ggp_socket_keep_source = true` to preserve the original marker node shape/name instead of replacing it.
5. Export glTF from Blender as usual.
6. Godot imports the asset with `GGP_SocketNodeModifier` enabled in the nearest relevant `GGP_ImportConfig`.
7. The imported/generated scene contains a named socket node at the authored transform. Designers or gameplay scripts can attach children under that socket and reset the child transform to snap to it.

## Proposed Imported Output

For a source marker named `@socket/Muzzle`, the importer should produce this shape:

```text
WeaponRoot
  MeshInstance3D
  Sockets
    Muzzle : Marker3D
```

The exact parent should be configurable:

- `preserve_source_parent = true`: create the socket under the imported parent that contained the source marker. This keeps transform inheritance closest to the Blender hierarchy.
- `socket_container_name = "Sockets"`: optionally group all sockets under a single `Node3D` container beneath the asset root or source parent.
- `strip_source_marker = true`: replace or remove the original glTF marker so users only see clean socket nodes.

Each socket node should carry metadata for runtime lookup and debugging:

```gdscript
metadata/ggp_socket = true
metadata/socket_name = "Muzzle"
metadata/source_node_name = "@socket/Muzzle"
metadata/source_extras = { ... }
```

`Marker3D` is the preferred output because it communicates intent in the editor while remaining a normal `Node3D`. If `Marker3D` is not appropriate for compatibility, `Node3D` is acceptable as a fallback.

## Modifier Design

Add `GGP_SocketNodeModifier extends GGP_NodeModifier` under `godot/godot_gltf_pipeline_addon/modifiers/socket/socket_node_modifier.gd`.

Suggested exported configuration, in addition to the inherited `enabled` flag from `GGP_NodeModifier`:

```gdscript
@export var socket_container_name: String = "Sockets"
@export var use_container: bool = true
@export var preserve_source_parent: bool = true
@export var strip_source_marker: bool = true
@export var metadata_key: String = "ggp_socket"
@export var name_prefixes: Array[String] = ["@socket/", "Socket_"]
@export var attach_scene_metadata_key: String = "ggp_socket_attach"
@export var instantiate_attachment_scenes: bool = false
@export var warn_on_duplicate_names: bool = true
```

Suggested hook usage:

- Use `process_node` to detect socket marker nodes after Godot has created a node with the imported transform.
- Read intent from `GGP_NodeUtility.get_extras(gltf_node)` and from `_get_name_from_gltf(gltf_node)` or `_get_name_from_node(node)`.
- Convert the marker to a `Marker3D`/`Node3D` while preserving local transform, owner, metadata, and children as appropriate.
- If `use_container` is enabled, create or reuse a `Sockets` container and reparent the socket while preserving global transform.
- Use `process_scene` for final duplicate-name validation or for building a socket registry on the root node.

The modifier should avoid mutating `GLTFState` unless there is a concrete reason. The source marker already imports as a normal node, so `process_node` is the simplest and safest phase.

## Attachment Scene Behavior

The first implementation should prioritize marker creation. Optional scene instantiation can be added behind `instantiate_attachment_scenes`:

- If `ggp_socket_attach` is set and scene instantiation is enabled, load the referenced `PackedScene` with `ResourceLoader`.
- Instantiate it as a child of the socket.
- Set the attachment's local transform to identity so it snaps to the socket.
- On load failure, keep the socket and attach error metadata or a lightweight placeholder, following the spirit of `GGP_PrefabModifier`'s error placeholder behavior.

This keeps socket lookup reliable even when an optional attachment is missing.

## Reimport and Customization Rules

The pipeline README states generated `.tscn` files are generated once and remain manually editable. Socket support should preserve that contract:

- Reimported `.glb` data should update the imported source scene and socket transforms.
- Existing user-edited customization scenes should not be overwritten.
- If users add children beneath generated socket nodes in a customization scene, those children should remain user-owned.
- The importer should not delete unrelated user nodes.
- Socket renames are breaking changes, just like renaming any scene node that gameplay scripts reference.

If the implementation later includes generated customization-scene updates, it must distinguish imported source nodes from user-authored children. That should be treated as a separate design problem.

## Ordering With Existing Modifiers

Recommended order for common import configs:

1. Asset processors such as texture/material/specular processors, if needed.
2. `GGP_NormalizeTransformNodeModifier`, so socket transforms inherit the normalized asset basis.
3. `GGP_SocketNodeModifier`, to convert authored socket markers into clean attachment points.
4. `GGP_DiscardNodeModifier`, if source markers or helper nodes should be removed by suffix conventions.
5. `GGP_PrefabModifier` and `GGP_ClassNodeModifier`, depending on whether sockets should host imported scenes or typed nodes.
6. Collision, light, dynamic mesh, and other specialized modifiers as currently configured.

The exact ordering should be validated against examples. The important rule is that sockets should see final normalized transforms and should not accidentally delete markers before converting them.

## Edge Cases

- Duplicate socket names under one asset: warn and either suffix Godot node names or include full source path in metadata.
- Duplicate socket names in different sub-assets: allow them when their asset roots differ.
- Source marker has mesh data: warn and keep the original node unless explicitly configured to convert mesh markers.
- Socket is nested under another socket: allow but warn, because attachment transforms can become surprising.
- Socket marker has children: preserve children by default when replacing the marker node.
- Invalid attach scene path: keep socket, warn, and record metadata for debugging.
- Missing or malformed extras: fall back to name detection when configured.
- Name cleanup conflicts: use existing `_get_name_from_gltf` and `_get_name_from_node` behavior so Blender `.001`/Godot `_001` suffixes are handled consistently.
- Interaction with `_Root`/`_Origin`: do not treat root/origin markers as sockets unless they explicitly include socket metadata.

## Runtime Usage Pattern

Gameplay code should not need importer internals. A script can find sockets by node path, group, or metadata:

```gdscript
var muzzle := weapon.find_child("Muzzle", true, false) as Node3D
if muzzle:
	var flash := muzzle_flash_scene.instantiate() as Node3D
	muzzle.add_child(flash)
	flash.transform = Transform3D.IDENTITY
```

A later helper API could provide a typed lookup function, for example `GGP_SocketUtility.find_socket(root, "Muzzle")`, but that is not required for the first modifier.

## Validation Plan

Unit-level GdUnit coverage should exercise the modifier without requiring a full Blender export:

- Metadata detection: `ggp_socket = "Name"` creates a socket named `Name`.
- Name detection: `@socket/Name` and `Socket_Name` are recognized when configured.
- Transform preservation: local transform remains stable when replacing a marker with `Marker3D`.
- Container behavior: sockets are grouped under `Sockets` when configured.
- Duplicate handling: duplicate names warn and remain deterministic.
- Optional attachment failure: missing scene path does not remove the socket.

Integration validation should include one small example asset:

- A glTF with at least two sockets under a static mesh.
- A Godot scene or test script that attaches a child scene to a socket and verifies identity local transform snaps it to the authored point.
- Headless project load with `godot --headless --path example/game --quit`.
- `just gdunit` when Godot and GdUnit are available.

## Open Questions

- Should the preferred Blender authoring path be custom properties only, or should a name convention be officially documented as equally supported?
- Should sockets be stored directly beside the source mesh, or always under a `Sockets` container for cleaner scene trees?
- Should optional scene attachment reuse `GGP_PrefabModifier` conventions, or live entirely inside the socket modifier?
- Should socket metadata use `ggp_socket` keys directly, or a nested dictionary such as `ggp = { socket = { name = "Muzzle" } }` for future extension?
- Should a helper runtime utility be part of the first implementation, or should the first version rely on normal Godot node lookup?
