class_name CharacterSlot
extends Panel

signal slot_clicked(slot: CharacterSlot)

@onready var character_id: String
@onready var character_name: Label = %CharacterName
@onready var character_level: Label = %Level
@onready var character_art: TextureRect = %TextureRect

var _is_selected: bool = false

func _ready() -> void:
	gui_input.connect(_on_gui_input)

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
			slot_clicked.emit(self)

func setup(_character_is: String, _character_name: String, _character_level: int, _character_class_texture: Texture2D) -> void:
	character_id = _character_is
	character_name.text = _character_name
	character_level.text = str(_character_level)
	character_art.texture = _character_class_texture

func set_selected(selected: bool) -> void:
	_is_selected = selected
	
	var style: StyleBoxFlat = get_theme_stylebox("panel")
	if style == null:
		style = StyleBoxFlat.new()
	else:
		style = style.duplicate()
	
	if _is_selected:
		style.border_color = Color(1.0, 1.0, 1.0, 1.0)
		style.border_width_left = 3
		style.border_width_right = 3
		style.border_width_top = 3
		style.border_width_bottom = 3
		add_theme_stylebox_override("panel", style)
	else:
		style.border_width_left = 0
		style.border_width_right = 0
		style.border_width_top = 0
		style.border_width_bottom = 0
		add_theme_stylebox_override("panel", style)
