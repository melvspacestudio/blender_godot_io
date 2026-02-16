## Represents a node type change modifier that can transform nodes between compatible types
## during a GLTF processing operation.
@tool
class_name HandleClassName extends NodeModifier

const EXTRAS_CLASS_NAME = &"class_name"

@export
var blacklist: Array[String] = []


func _should_process(node: Node) -> bool:
	var extras = _get_extras(node)
	var classname = extras.get(EXTRAS_CLASS_NAME)
	
	if classname is String and not classname.is_empty():
		return (ClassDB.class_exists(classname) and classname not in blacklist)

	return false


func _process_node(node: Node) -> Node:
	var extras = _get_extras(node)
	var classname = extras.get(EXTRAS_CLASS_NAME)
	
	var new_node = ClassDB.instantiate(classname)
	new_node.name = node.name
	
	if node is Node3D and new_node is Node3D:
		new_node.transform = node.transform

	for meta_item in node.get_meta_list():
		new_node.set_meta(meta_item, node.get_meta(meta_item))

	node.replace_by(new_node, true)
	
	var processed_node = _handle_special_node_types(node, new_node)
	
	node.queue_free()

	return processed_node
	

func _handle_special_node_types(original_node: Node, next_node: Node) -> Node:
	if next_node is ReflectionProbe:
		if original_node is ImporterMeshInstance3D:
			var mesh_instance = original_node as ImporterMeshInstance3D
			var reflection_probe = next_node as ReflectionProbe
			
			# Apply any parameters defined in extras
			var apply_params_modifier = ApplyParams.new()
			if apply_params_modifier.should_process(reflection_probe):
				reflection_probe = apply_params_modifier.process(reflection_probe) as ReflectionProbe
			
			var aabb = mesh_instance.mesh.get_mesh().get_aabb()
			reflection_probe.size = aabb.size + Vector3.ONE * reflection_probe.blend_distance * 2
			return reflection_probe

	if next_node is CollisionShape3D:
		if original_node is ImporterMeshInstance3D:
			var mesh_instance = original_node as ImporterMeshInstance3D
			var collision_shape = next_node as CollisionShape3D
			
			var shape = CollisionShapeUtility.create_convex_shape_from_array_mesh(mesh_instance.mesh.get_mesh())
			collision_shape.shape = shape
			return collision_shape
		
	return next_node
