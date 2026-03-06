@tool
class_name QMIndex extends Resource

@export
var name: String = "Group"

@export
var key: Key = KEY_NONE

var path: String :
	get(): return "/".join(resource_path.split("/").slice(0, -1))

func load_groups() -> Array[QMIndex]:
	var folders = DirAccess.get_directories_at(path)
	var groups: Array[QMIndex] = []
	
	for folder in folders:
		var group = load(path.path_join(folder).path_join("index.tres"))
		if group is not QMIndex:
			continue
			
		groups.append(group)
		
	return groups

func load_actions() -> Array[QMAction]:
	var files = DirAccess.get_files_at(path)
	var actions: Array[QMAction] = []
	
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
	
	return actions
	

		
