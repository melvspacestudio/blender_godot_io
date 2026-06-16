@tool
class_name GGP_TestRecordingModifier extends GGP_NodeModifier

static var events: Array[String] = []

@export
var marker: String = ""


static func reset() -> void:
	events.clear()


func pre_generate(state: GLTFState) -> Error:
	events.append(marker)
	return OK
