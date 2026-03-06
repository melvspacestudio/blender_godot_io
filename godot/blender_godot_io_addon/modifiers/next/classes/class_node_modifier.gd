@tool
class_name BGIO_ClassNodeModifier extends BGIO_NodeModifier

@export
var blacklist: Array[String] = []

@export
var factories: Array[BGIO_ClassFactory] = [
	BGIO_ReflectionProbe_ClassFactory.new(),
]

var default_factory: BGIO_ClassFactory = BGIO_ClassFactory.new()


func generate_node(state: GLTFState, gltf_node: GLTFNode, scene_parent: Node, node: Node) -> Node:
	if node: return node
	
	var _class_name = BGIO_ClassModifier_Utility.get_classname(gltf_node)
	if _class_name.is_empty(): return node
	if _class_name in blacklist: return node
	
	for factory in factories:
		if factory.can_generate(state, gltf_node, scene_parent, node):
			return factory.generate_node(state, gltf_node, scene_parent, node)
		
	return default_factory.generate_node(state, gltf_node, scene_parent, node)
