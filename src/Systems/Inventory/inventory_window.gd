class_name InventoryWindow
extends PanelContainer

@onready var inventory: Inventory = %Inventory
@onready var equipment: Equipment = %Equipment

func _ready() -> void:
	visible = false
	_initialize_systems()

func _initialize_systems() -> void:
	await get_tree().process_frame
	
	if inventory and equipment:
		var drag_manager := inventory.get_drag_manager()
		equipment.initialize(drag_manager, inventory)

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
