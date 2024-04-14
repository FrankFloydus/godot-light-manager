@tool
class_name OmniCustom extends OmniLight3D


func _set(property: StringName, value: Variant) -> bool:
	if property == "light_energy":
		notify_property_list_changed()
	return true
