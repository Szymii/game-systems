class_name SelectableClass
extends PanelContainer

signal class_selected(selectable_class: PanelContainer)

@export var character_class_res: CharacterClass

@onready var _class_name: Label = %ClassName
@onready var _character_art: TextureRect = %CharacterArt

var _is_selected: bool = false

func _ready() -> void:
	_display_class_name()
	_display_character_art()
	_setup_input()

func _setup_input() -> void:
	gui_input.connect(_on_gui_input)

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
			class_selected.emit(self)

func set_selected(selected: bool) -> void:
	_is_selected = selected
	
	if _is_selected:
		add_theme_stylebox_override("panel", _create_selected_style())
	else:
		remove_theme_stylebox_override("panel")

func get_character_class() -> CharacterClassList.CHARACTER_CLASS_LIST:
	return character_class_res.character_class

func get_character_art() -> String:
	return character_class_res.character_art.resource_path

func _create_selected_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.2, 0.2, 0.2, 1.0)
	style.border_color = Color(1.0, 1.0, 1.0, 1.0)
	style.border_width_left = 3
	style.border_width_right = 3
	style.border_width_top = 3
	style.border_width_bottom = 3
	return style

func _display_class_name() -> void:
	if character_class_res == null:
		return
	
	var class_name_text: String = CharacterClassList.CHARACTER_CLASS_LIST.keys()[character_class_res.character_class - 1]
	_class_name.text = class_name_text.capitalize()

func _display_character_art() -> void:
	if character_class_res == null:
		return
	
	_character_art.texture = character_class_res.character_art
