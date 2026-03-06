@tool
extends EditorPlugin

var extension: BlenderGodotIO_GLTF_Extension = BlenderGodotIO_GLTF_Extension.new()

func _enter_tree():
	# Register extension
	GLTFDocument.register_gltf_document_extension(extension)


func _exit_tree():
	# Unregister extension
	GLTFDocument.unregister_gltf_document_extension(extension)
