@tool
class_name GLTFTargetFolder extends Resource

## Folder to import scenes from, extension will not run on files outside this directory
@export_dir var folder: String

## Apply extension to any subfolders of the specified scenes folder
@export var allow_subfolders: bool = true
