extends MarginContainer

signal modal_closed()

@onready var Name: LineEdit = %Name
@onready var CreateBtn: Button = %CreateBtn
@onready var CloseBtn: Button = %CloseBtn

var _selected_class: SelectableClass = null
var _character_name: String = ""

func _ready() -> void:
	_connect_selectable_classes()
	_connect_ui_elements()

func _input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		_close_modal()
		get_viewport().set_input_as_handled()

func _connect_selectable_classes() -> void:
	var hbox := %HSelectableContainer
	for child in hbox.get_children():
		if child.has_signal("class_selected"):
			child.connect("class_selected", _on_class_selected)

func _connect_ui_elements() -> void:
	Name.text_changed.connect(_on_name_changed)
	CreateBtn.pressed.connect(_on_create_btn_pressed)
	CloseBtn.pressed.connect(_close_modal)

func _on_class_selected(selectable_class: SelectableClass) -> void:
	if _selected_class != null and _selected_class.has_method("set_selected"):
		_selected_class.call("set_selected", false)
	
	_selected_class = selectable_class
	if _selected_class.has_method("set_selected"):
		_selected_class.call("set_selected", true)

func _on_name_changed(new_text: String) -> void:
	_character_name = new_text

func _on_create_btn_pressed() -> void:
	if _character_name and _selected_class:
		SavesManager.create_and_save(_character_name, _selected_class.get_character_class(), _selected_class.get_character_art())
		modal_closed.emit()
	pass

func _close_modal() -> void:
	modal_closed.emit()
