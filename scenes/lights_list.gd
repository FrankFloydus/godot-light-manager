@tool
class_name LightList extends Control

@export var light_entry: PackedScene
@onready var empty: PanelContainer = %Empty
@onready var list: VBoxContainer = %List
@onready var disable_volumetrics_button: Button = %"Disable Volumetrics"
@onready var sync_button: Button = %Sync
@onready var quick_settings: VBoxContainer = $QuickSettings


var undo_redo: EditorUndoRedoManager
var copied_settings: Dictionary


func _ready() -> void:
	disable_volumetrics_button.pressed.connect(on_disable_volumetrics)
	sync_button.pressed.connect(on_sync_button_pressed)
	list.child_order_changed.connect(on_child_order_changed)


func on_child_order_changed():
	print(list.get_child_count())
	if list.get_child_count() == 0:
		quick_settings.hide()
	else:
		quick_settings.show()


func on_sync_button_pressed():
	var lights = list.get_children() as Array[LightEntry]
	for light in lights:
		var _synced_light = light._edited_light as OmniLight3D
		light.light_volumetric.value = _synced_light.light_volumetric_fog_energy 
		light.light_energy.value = _synced_light.light_energy
		light.light_range.value = _synced_light.omni_range
		light.light_specular.value = _synced_light.light_specular
		light.light_color.color = _synced_light.light_color
		light.light_toggle.button_pressed = _synced_light.visible


func on_disable_volumetrics():
	var lights = list.get_children() as Array[LightEntry]
	for light in lights:
		undo_redo.create_action("Disable Volumetrics")
		undo_redo.add_undo_property(light.light_volumetric, "value", light.light_volumetric.value)
		light.light_volumetric.value = 0
		undo_redo.commit_action()


func add_entry(light: OmniLight3D):
	var light_entry_instance = light_entry.instantiate() as LightEntry
	light_entry_instance.undo_redo = undo_redo
	light_entry_instance._edited_light = light
	list.add_child(light_entry_instance)
	light_entry_instance.settings_copied.connect(on_settings_copied)
	light_entry_instance.request_settings.connect(on_paste_settings.bind(light_entry_instance))


func on_paste_settings(light_entry_instance: LightEntry):
	if !copied_settings.is_empty():
		light_entry_instance.apply_copied_settings(copied_settings)


func on_settings_copied(settings: Dictionary):
	copied_settings = settings
	Utils.print_dictionary(settings)


func show_list():
	list.show()
	empty.hide()
	
	
func show_empty():
	list.hide()
	empty.show()


func clear():
	var childrens: Array[Node] = list.get_children()
	if childrens.size() > 0:
		for children in childrens:
			children.queue_free()
