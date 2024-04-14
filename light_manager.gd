@tool
extends EditorPlugin

"""
TODO: 
	- Copy / Paste Settings
	- Global Toggles: disable all volumetrics, disable enable all
"""

var light_manager_panel = preload("res://addons/lightmanager/scenes/lights_list.tscn")
var light_manager_docked_panel: LightList
var undo_redo: EditorUndoRedoManager = get_undo_redo()


func _get_plugin_name() -> String:
	return "LightManager"


func get_current_scene_lights() -> Array[Node]:
	var lights = get_tree().edited_scene_root.find_children("", "OmniLight3D", true, false)
	# add_lights_to_group(lights)
	return lights

func on_property_changed():
	print("CHANGED")



func _enter_tree() -> void:
	
	# We init the dockable panel
	print("ENTER TREE")
	initialize_light_manager()
	
	
	if get_tree().get_edited_scene_root() != null:
		print("Edited Scene Root: " + get_tree().edited_scene_root.name)
		var lights = get_current_scene_lights() as Array[OmniLight3D] 
		print(lights)
		if lights.size() > 0:
			update_light_list(lights)
	
	
	# We connect to the scene change signal, so we can detect lights in other scenes
	scene_changed.connect(on_scene_changed)
	
	
	#update_light_list(lights)

func on_scene_changed(root: Node):
	if root != null:
		var lights = get_current_scene_lights() as Array[OmniLight3D] 
		update_light_list(lights)


func _exit_tree() -> void:
	destroy_light_manager()


func initialize_light_manager() -> void:
	light_manager_docked_panel = light_manager_panel.instantiate()
	light_manager_docked_panel.undo_redo = undo_redo
	add_control_to_dock(DOCK_SLOT_RIGHT_BL, light_manager_docked_panel)


func destroy_light_manager() -> void:
	remove_control_from_docks(light_manager_docked_panel)
	light_manager_docked_panel.free()


func update_light_list(lights: Array[Node]) -> void:
	light_manager_docked_panel.clear()
	add_existing_lights_to_panel(lights)

func add_existing_lights_to_panel(lights: Array[Node]) -> void:
	print(get_tree().edited_scene_root)
	for light in lights:
		light_manager_docked_panel.add_entry(light as OmniLight3D)

