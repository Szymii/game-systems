class_name Inventory
extends PanelContainer

@export var items: Array[ItemData] = []
@export var inventory_item_scene: PackedScene
@onready var item_grid: ItemGrid = %ItemGrid

func _ready() -> void:
	_load_saved_inventory()
	Global.try_pick_up_item_signal.connect(_try_add_item)

func _try_add_item(item_data: ItemData, callback: Callable) -> void:
	var inventory_item: InventoryItem = inventory_item_scene.instantiate()
	inventory_item.data = item_data
	var success := item_grid.attempt_to_add_item_data(inventory_item, func() -> void:
		add_child(inventory_item)
		_save_inventory(Global.current_character_id)
	)

	if success:
		callback.call()

func _save_inventory(_character_id: String) -> void:
	var saved_items := item_grid.get_save_data()
	SavesManager.save_inventory(_character_id, saved_items)

func _load_saved_inventory() -> void:
	if Global.current_character_id.is_empty():
		return
	
	var character_data := SavesManager.load_character_data(Global.current_character_id)
	if character_data and character_data.inventory_items.size() > 0:
		load_inventory_from_data(character_data.inventory_items)

func load_inventory_from_data(saved_items: Array[SavedInventoryItem]) -> void:
	item_grid.load_from_save_data(saved_items, inventory_item_scene, self)
