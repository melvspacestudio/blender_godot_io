class_name CollisionShapeUtility extends RefCounted


static func create_convex_shape_from_array_mesh(array_mesh: ArrayMesh, surface_index: int = 0) -> ConvexPolygonShape3D:
	if not array_mesh:
		push_error("ArrayMesh is null")
		return null
	
	if array_mesh.get_surface_count() == 0:
		push_error("ArrayMesh has no surfaces")
		return null
	
	var all_vertices = PackedVector3Array()
	
	# If surface_index is -1, combine all surfaces
	if surface_index == -1:
		for i in range(array_mesh.get_surface_count()):
			var vertices = _extract_vertices_from_surface(array_mesh, i)
			if vertices:
				all_vertices.append_array(vertices)
	else:
		# Use specific surface
		if surface_index >= array_mesh.get_surface_count():
			push_error("Surface index %d is out of range (max: %d)" % [surface_index, array_mesh.get_surface_count() - 1])
			return null
		
		all_vertices = _extract_vertices_from_surface(array_mesh, surface_index)
	
	if all_vertices.is_empty():
		push_error("No vertices found in ArrayMesh")
		return null
	
	# Create the convex shape
	var convex_shape = ConvexPolygonShape3D.new()
	convex_shape.points = all_vertices
	
	return convex_shape


## Helper function to extract vertices from a specific surface
static func _extract_vertices_from_surface(array_mesh: ArrayMesh, surface_idx: int) -> PackedVector3Array:
	var arrays = array_mesh.surface_get_arrays(surface_idx)
	
	if arrays.size() <= Mesh.ARRAY_VERTEX or not arrays[Mesh.ARRAY_VERTEX]:
		push_warning("Surface %d has no vertex data" % surface_idx)
		return PackedVector3Array()
	
	return arrays[Mesh.ARRAY_VERTEX] as PackedVector3Array
