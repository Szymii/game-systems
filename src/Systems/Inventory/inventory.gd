class_name Inventory
extends PanelContainer

@export var items: Array[ItemData] = []
@export var inventory_item_scene: PackedScene
@onready var item_grid: ItemGrid = %ItemGrid

func _ready() -> void:
	for i in items:
		_add_item(i)
	
	Global.try_pick_up_item_signal.connect(_try_add_item)

func _try_add_item(item_data: ItemData, callback: Callable) -> void:
	var inventory_item: InventoryItem = inventory_item_scene.instantiate()
	inventory_item.data = item_data
	var success := item_grid.attempt_to_add_item_data(inventory_item, func() -> void: add_child(inventory_item))

	if success:
		callback.call()

func _add_item(item_data: ItemData) -> void:
	var inventory_item: InventoryItem = inventory_item_scene.instantiate()
	inventory_item.data = item_data
	item_grid.attempt_to_add_item_data(inventory_item, func() -> void: add_child(inventory_item))
