@tool
class_name QMTree extends RefCounted

var actions: Array[QMAction]
var groups: Array[QMIndex]

static func load_tree(path: String) -> QMTree:
	var files = DirAccess.get_files_at(path)
	var folders = DirAccess.get_directories_at(path)

	var actions: Array[QMAction] = []
	var groups: Array[QMIndex] = []

	for folder in folders:
		var group = load(path.path_join(folder).path_join("index.tres"))
		if group is not QMIndex:
			continue

		groups.append(group)

	for file in files:
		if not file.ends_with(".gd"):
			continue

		var Action = load(path.path_join(file))
		if Action is not GDScript:
			continue

		var action = Action.new()
		if action is not QMAction:
			continue

		actions.append(action)

	var tree = QMTree.new()
	tree.groups = groups
	tree.actions = actions

	return tree
