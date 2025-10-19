class_name InventoryWindow
extends PanelContainer

func _ready() -> void:
	visible = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		toggle_visibility()

func toggle_visibility() -> void:
	visible = !visible
