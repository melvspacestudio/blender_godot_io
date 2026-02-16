@tool
class_name CreateCollisions extends NodeModifier

const EXTRAS_COLLISION = &"collision"
const EXTRAS_MESH = &"mesh"
const EXTRAS_CENTER_X = &"center_x"
const EXTRAS_CENTER_Y = &"center_y"
const EXTRAS_CENTER_Z = &"center_z"
const EXTRAS_SIZE_X = &"size_x"
const EXTRAS_SIZE_Y = &"size_y"
const EXTRAS_SIZE_Z = &"size_z"
const EXTRAS_HEIGHT = &"height"
const EXTRAS_RADIUS = &"radius"

const TYPE_SIMPLE = "simple"
const TYPE_TRIMESH = "trimesh"
const TYPE_BOX = "box"
const TYPE_CYLINDER = "cylinder"
const TYPE_SPHERE = "sphere"
const TYPE_CAPSULE = "capsule"
const TYPE_COL_ONLY = "-c"

var _collision_map: Dictionary = {}

func _should_process(node: Node):
	var extras = _get_extras(node)
	var collision = extras.get(EXTRAS_COLLISION)

	return node is PhysicsBody3D and collision != null
	

func _process_node(node: Node) -> Node:
	var extras = _get_extras(node)
	var collision = extras[EXTRAS_COLLISION]
	
	return _collisions(node, collision, extras)


## Generates a collision body for a given node based on metadata
## 
## Supports creating different types of collision bodies (StaticBody3D, RigidBody3D, Area3D, etc.)
## with various shape types (box, cylinder, sphere, capsule) and collision generation modes.
## 
## @param node The source node to create a collision body for
## @param collision Metadata string defining collision body type and properties
## @param extras Dictionary containing additional configuration details
## @return Node The generated collision body or modified original node
func _collisions(node: PhysicsBody3D, collision: String, extras: Dictionary) -> Node:
	var target_mesh: String = extras.get(EXTRAS_MESH, "")
	
	var simple: bool = TYPE_SIMPLE in collision
	var trimesh: bool = TYPE_TRIMESH in collision
	
	var mesh_instance: ImporterMeshInstance3D
	if target_mesh:
		mesh_instance = node.get_node(target_mesh)
	else:
		mesh_instance = _find_mesh_instance(node)

	var collision_shape = CollisionShape3D.new()
	collision_shape.name = "CollisionShape3D_" + node.name
	
	var col_only = TYPE_COL_ONLY in collision
	collision_shape.scale = node.scale
	collision_shape.rotation = node.rotation

	if simple or trimesh:
		if not mesh_instance:
			push_warning("No mesh instance found, cannot create convex/concave collision")
			return node

		var collision_shapes = _get_mesh_collisions(mesh_instance, not simple)
		if collision_shapes.size() > 0:
			collision_shape.shape = collision_shapes[0]
	
	if not simple and not trimesh:
		if extras.has(EXTRAS_CENTER_X) and extras.has(EXTRAS_CENTER_Y) and extras.has(EXTRAS_CENTER_Z):
			var center_x = float(extras.get(EXTRAS_CENTER_X))
			var center_y = float(extras.get(EXTRAS_CENTER_Y))
			var center_z = - float(extras.get(EXTRAS_CENTER_Z))
			collision_shape.position += Vector3(center_x, center_y, center_z)
	
	if TYPE_BOX in collision:
		if extras.has(EXTRAS_SIZE_X) and extras.has(EXTRAS_SIZE_Y) and extras.has(EXTRAS_SIZE_Z):
			var box = BoxShape3D.new()
			var size_x = float(extras.get(EXTRAS_SIZE_X))
			var size_y = float(extras.get(EXTRAS_SIZE_Y))
			var size_z = float(extras.get(EXTRAS_SIZE_Z))
			box.size = Vector3(size_x, size_y, size_z)
			collision_shape.shape = box
	
	elif TYPE_CYLINDER in collision:
		if extras.has(EXTRAS_HEIGHT) and extras.has(EXTRAS_RADIUS):
			var cylinder = CylinderShape3D.new()
			var height = float(extras.get(EXTRAS_HEIGHT))
			var radius = float(extras.get(EXTRAS_RADIUS))
			cylinder.height = height
			cylinder.radius = radius
			collision_shape.shape = cylinder
	
	elif TYPE_SPHERE in collision:
		if extras.has(EXTRAS_RADIUS):
			var sphere = SphereShape3D.new()
			var radius = float(extras.get(EXTRAS_RADIUS))
			sphere.radius = radius
			collision_shape.shape = sphere
	
	elif TYPE_CAPSULE in collision:
		if extras.has(EXTRAS_HEIGHT) and extras.has(EXTRAS_RADIUS):
			var capsule = CapsuleShape3D.new()
			var height = float(extras.get(EXTRAS_HEIGHT))
			var radius = float(extras.get(EXTRAS_RADIUS))
			capsule.height = height
			capsule.radius = radius
			collision_shape.shape = capsule
	
	if collision_shape.shape == null:
		push_warning("No collision shape found, cannot create collision for node: %s" % node.name)
		collision_shape.free()
		return node
	
	if col_only and mesh_instance:
		mesh_instance.free()
		
	node.add_child(collision_shape)
	collision_shape.owner = node.owner

	return node
	

## Recursively searches for the first MeshInstance3D child within a given node and its descendants
## 
## @param node: The starting node to search for a MeshInstance3D
## @return MeshInstance3D: The first MeshInstance3D found, or null if no MeshInstance3D exists
func _find_mesh_instance(node: Node) -> ImporterMeshInstance3D:
	for child in node.get_children():
		if child is ImporterMeshInstance3D:
			return child
		
		var found = _find_mesh_instance(child)
		if found:
			return found

	return null


func _get_mesh_collisions(node: ImporterMeshInstance3D, include_convex: bool) -> Array[Shape3D]:
	var mesh = node.mesh
	var shapes: Array[Shape3D] = []

	if _collision_map.has(mesh):
		shapes = _collision_map[mesh]
	else:
		shapes = _pre_gen_shape_list(mesh, include_convex)
		_collision_map[mesh] = shapes
	
	return shapes
 
 
func _pre_gen_shape_list(mesh: ImporterMesh, p_convex: bool) -> Array[Shape3D]:
	if !p_convex:
		var shape: ConcavePolygonShape3D = mesh.create_trimesh_shape()
		return [shape]
	else:
		var shapes: Array[Shape3D] = []
		shapes.push_back(mesh.create_convex_shape(true,  false))
		return shapes
