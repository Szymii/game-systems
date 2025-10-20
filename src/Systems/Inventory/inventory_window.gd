class_name InventoryWindow
extends PanelContainer

@onready var inventory: Inventory = %Inventory

func _ready() -> void:
	visible = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		toggle_visibility()

func toggle_visibility() -> void:
	if visible:
		_try_drop_held_item_before_close()
	
	visible = !visible

func _try_drop_held_item_before_close() -> void:
	if inventory:
		inventory.try_drop_held_item()
