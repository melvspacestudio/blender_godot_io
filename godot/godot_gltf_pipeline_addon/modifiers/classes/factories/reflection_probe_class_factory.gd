@tool
class_name GGP_ReflectionProbe_ClassFactory extends GGP_ClassFactory

func can_generate(state: GLTFState, gltf_node: GLTFNode, scene_parent: Node, node: Node) -> bool:
	var _class_name = GGP_ClassModifier_Utility.get_classname(gltf_node)
	return _class_name == "ReflectionProbe"

func generate_node(state: GLTFState, gltf_node: GLTFNode, scene_parent: Node, node: Node) -> Node:
	var reflection_probe_parent = Node3D.new()
	reflection_probe_parent.name = gltf_node.resource_name
	
	if gltf_node.mesh == -1:
		return reflection_probe_parent

	var mesh: GLTFMesh = state.get_meshes()[gltf_node.mesh]
	var aabb: AABB = mesh.mesh.get_mesh().get_aabb()
	
	var reflection_probe = super.create_class_instance(state, gltf_node, scene_parent, node)
	if reflection_probe is ReflectionProbe:
		reflection_probe.size = aabb.size + Vector3.ONE * 2
		reflection_probe.position = aabb.position + aabb.size / 2
	
	reflection_probe_parent.add_child(reflection_probe)
	return reflection_probe_parent
