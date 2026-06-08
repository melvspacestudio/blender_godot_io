@tool
class_name GGP_ClassNodeModifier extends GGP_NodeModifier

@export
var blacklist: Array[String] = []

@export
var factories: Array[GGP_ClassFactory] = [
	GGP_ReflectionProbe_ClassFactory.new(),
]

var default_factory: GGP_ClassFactory = GGP_ClassFactory.new()


func generate_node(state: GLTFState, gltf_node: GLTFNode, scene_parent: Node, node: Node) -> Node:
	if node: return node

	var requested_classname := GGP_ClassModifier_Utility.get_requested_classname(gltf_node)
	if requested_classname.is_empty(): return node
	if requested_classname in blacklist: return node
	if not ClassDB.class_exists(requested_classname):
		if GGP_ClassModifier_Utility.has_explicit_classname(gltf_node):
			push_warning("Could not instantiate imported class `%s`: class does not exist. Keeping original node." % requested_classname)
		return node

	for factory in factories:
		if factory.can_generate(state, gltf_node, scene_parent, node):
			return _generate_with_factory(factory, state, gltf_node, scene_parent, node, requested_classname)

	return _generate_with_factory(default_factory, state, gltf_node, scene_parent, node, requested_classname)


func _generate_with_factory(factory: GGP_ClassFactory, state: GLTFState, gltf_node: GLTFNode, scene_parent: Node, node: Node, requested_classname: String) -> Node:
	var generated_node := factory.generate_node(state, gltf_node, scene_parent, node)
	if generated_node:
		return generated_node

	var reason := factory.last_generation_error
	if reason.is_empty():
		reason = "factory did not generate a Node"
	push_warning("Could not instantiate imported class `%s`: %s. Keeping original node." % [requested_classname, reason])
	return node
