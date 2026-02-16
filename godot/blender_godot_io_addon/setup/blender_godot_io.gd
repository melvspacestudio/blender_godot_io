@tool
extends EditorPlugin

var dock: Node
var extension: BlenderGodotIO_GLTF_Extension = BlenderGodotIO_GLTF_Extension.new()

func _enter_tree():
	# Setup project settings
	BlenderGodotIOSettings.init_configuration_path()
	
	# Register extension
	GLTFDocument.register_gltf_document_extension(extension)

	# Register extensions
	var config = BlenderGodotIOConfiguration.get_current_config()
	if config:
		config.register()


func _exit_tree():
	# Unregister extension
	GLTFDocument.unregister_gltf_document_extension(extension)
	
	# Unregister extensions
	var config = BlenderGodotIOConfiguration.get_current_config()
	if config:
		config.unregister()
