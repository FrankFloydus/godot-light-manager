@tool
class_name LightEntry extends PanelContainer

signal settings_copied(settings: Dictionary)
signal request_settings

@onready var copy_settings: Button = %"Copy Settings"
@onready var paste_settings: Button = %"Paste Settings"
@onready var light_toggle: CheckButton = %LightToggle
@onready var light_color: ColorPickerButton = %LightColor
@onready var light_energy: HSlider = %LightIntensity
@onready var button: Button = %Button
@onready var light_range: HSlider = %LightRange
@onready var light_volumetric: HSlider = %LightVolumetric
@onready var light_specular: HSlider = %LightSpecular

var _edited_light: OmniLight3D
var undo_redo: EditorUndoRedoManager

func _ready() -> void:
	
	if _edited_light == null:
		return
	
	# On / Off
	light_toggle.toggled.connect(on_light_toggled)
	
	# Color Picker
	light_color.pressed.connect(on_picker_opened)
	light_color.popup_closed.connect(on_picker_closed)
	light_color.color_changed.connect(on_color_changed)
	
	# Energy
	light_energy.drag_started.connect(on_light_energy_drag_started)
	light_energy.drag_ended.connect(on_light_energy_drag_ended)
	light_energy.value_changed.connect(on_light_value_changed)
	
	# Range
	light_range.value_changed.connect(on_light_range_value_changed)
	
	# Volumetric
	light_volumetric.value_changed.connect(on_light_volumetric_energy_value_changed)
	
	# Specular
	light_specular.value_changed.connect(on_light_specular_value_changed)
	
	# Name
	button.pressed.connect(on_selection)
	
	copy_settings.pressed.connect(on_copy_settings_pressed)
	paste_settings.pressed.connect(on_paste_settings_pressed)
	
	if _edited_light != null:
		_edited_light.renamed.connect(on_rename)
		_edited_light.property_list_changed.connect(on_property_changed)
		_edited_light.visibility_changed.connect(on_property_changed)
		print(_edited_light)
	update_entry_data()

func on_property_changed():
	print("CHANGED")
	

func on_paste_settings_pressed():
	request_settings.emit()


func on_copy_settings_pressed():
	var settings = {
		"light_toggle" = _edited_light.visible,
		"light_color" = _edited_light.light_color,
		"light_energy" = _edited_light.light_energy,
		"light_range" = _edited_light.omni_range,
		"light_volumetric" = _edited_light.light_volumetric_fog_energy,
		"light_specular" = _edited_light.light_specular
	}
	settings_copied.emit(settings)


func apply_copied_settings(settings: Dictionary):
	if settings.is_empty():
		return
		
	light_toggle.button_pressed = settings["light_toggle"]
	_edited_light.visible =  settings["light_toggle"]
	
	light_color.color = settings["light_color"]
	_edited_light.light_color = settings["light_color"]
	
	light_energy.value = settings["light_energy"]
	_edited_light.light_energy = settings["light_energy"]
	
	light_range.value = settings["light_range"]
	_edited_light.omni_range = settings["light_range"]
	
	light_volumetric.value = settings["light_volumetric"]
	_edited_light.light_volumetric_fog_energy = settings["light_volumetric"]
	
	light_specular.value = settings["light_specular"]
	_edited_light.light_specular = settings["light_specular"]

func update_entry_data():
	if _edited_light != null:
		button.text = _edited_light.name
		light_toggle.button_pressed = _edited_light.visible
		light_color.color = _edited_light.light_color
		light_energy.value = _edited_light.light_energy
		light_range.value = _edited_light.omni_range
		light_volumetric.value = _edited_light.light_volumetric_fog_energy
		light_specular.value = _edited_light.light_specular


func sync_light_color(color: Color):
	light_color.color = color
	_edited_light.light_color = color


func sync_light_energy(value: float):
	light_energy.value = value
	_edited_light.light_energy = value


func on_picker_opened():
	undo_redo.create_action("Change Light Color", UndoRedo.MERGE_DISABLE, self)
	undo_redo.add_undo_method(self, "sync_light_color", light_color.color)


func on_picker_closed():
	undo_redo.commit_action()


func on_selection():
	var selection = EditorInterface.get_selection() as EditorSelection
	selection.clear()
	selection.add_node(_edited_light)


func on_rename():
	button.text = _edited_light.name


func on_light_toggled(toggled_status: bool):
	_edited_light.visible = toggled_status


func on_color_changed(color: Color):
	_edited_light.light_color = color


func on_light_range_value_changed(value: float):
	_edited_light.omni_range = value


func on_light_volumetric_energy_value_changed(value: float):
	_edited_light.light_volumetric_fog_energy = value


func on_light_specular_value_changed(value: float):
	_edited_light.light_specular = value


func on_light_energy_drag_started():
	undo_redo.create_action("Change Light Energy", UndoRedo.MERGE_DISABLE, self)
	undo_redo.add_undo_method(self, "sync_light_energy", light_energy.value)


func on_light_energy_drag_ended(value: bool):
	if value:
		undo_redo.commit_action()


func on_light_value_changed(value: float):
	_edited_light.light_energy = value
