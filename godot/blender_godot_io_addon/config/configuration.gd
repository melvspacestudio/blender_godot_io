@tool
@icon("res://addons/blender_godot_io_addon/logo.svg")
class_name BlenderGodotIOConfiguration extends Resource

@export_tool_button("Activate this configuration")
var set_as_main_configuration: Callable = _set_as_main_configuration

@export_category("Data")
@export
var extensions: Array[GLTFDocumentExtension] = [] :
	set(value):
		if _is_registered:
			_unregister()
			
		extensions = value
		
		if _is_registered:
			_register()
		
var _is_registered: bool = false

var is_active: bool :
	get: return BlenderGodotIOConfiguration.get_current_config() == self


static func get_current_config() -> BlenderGodotIOConfiguration:
	var path: String = BlenderGodotIOSettings.get_configuration_path()
	if path.is_empty(): 
		return null
		
	if not ResourceLoader.exists(path):
		return null
		
	var resource = load(path)
	if resource is not BlenderGodotIOConfiguration:
		push_warning("Invalid resource provided in settings at path: %s. BlenderGodotIOConfiguration is expected." % path)
		return null
		
	return resource


func _register() -> void:
	for extension in extensions:
		if extension:
			GLTFDocument.register_gltf_document_extension(extension)


func _unregister() -> void:
	for extension in extensions:
		if extension:
			GLTFDocument.unregister_gltf_document_extension(extension)


func register() -> void:
	if _is_registered:
		return
	print("Registering %s extensions" % extensions.size())
	_register()
	_is_registered = true


func unregister() -> void:
	if not _is_registered:
		return
	print("Unregistering %s extensions" % extensions.size())
	_unregister()
	_is_registered = false


func _set_as_main_configuration() -> void:
	var current_config = BlenderGodotIOConfiguration.get_current_config()
	if current_config == self:
		print("This configuration is already active")
		return
	
	if current_config: 
		current_config.unregister()
	
	BlenderGodotIOSettings.set_configuration_path(resource_path)

	var new_config = BlenderGodotIOConfiguration.get_current_config()
	if new_config: 
		new_config.register()
