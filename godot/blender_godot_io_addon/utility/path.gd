@tool
class_name PathUtils extends Object

static func resource_dir(resource: Resource) -> String:
	var dir = resource.resource_path.replace("res://", "").split("/")
	dir.remove_at(dir.size() - 1)
	
	return "res://" + "/".join(dir)


static func resolve(dir: String) -> String:
	if dir.begins_with("res://"):
		return dir
		
	if dir.begins_with("/"):
		return dir

	return "res://" + dir

static func resolve_at(resource: Resource, dir: String) -> String:
	if dir.begins_with("res://"):
		return dir
		
	if dir.begins_with("/"):
		return dir

	return resource_dir(resource).path_join(dir)
