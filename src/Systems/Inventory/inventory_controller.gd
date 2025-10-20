class_name InventoryController
extends RefCounted

signal item_added_to_inventory(item_data: ItemData, slot_index: int)
signal item_removed_from_inventory(item_data: ItemData, slot_index: int)
signal inventory_saved()
signal inventory_loaded()

var data: InventoryData
var character_id: String

func _init(_data: InventoryData, _character_id: String = "") -> void:
	data = _data
	character_id = _character_id
	
	data.item_added.connect(_on_item_added)
	data.item_removed.connect(_on_item_removed)
	data.inventory_changed.connect(_on_inventory_changed)

func try_add_item(item_data: ItemData) -> bool:
	var slot_index := data.add_item(item_data)
	if slot_index >= 0:
		_auto_save()
		return true
	return false

func try_add_item_at_slot(item_data: ItemData, slot_index: int) -> bool:
	var result := data.add_item(item_data, slot_index)
	if result >= 0:
		_auto_save()
		return true
	return false

func remove_item_at_slot(slot_index: int) -> ItemData:
	var item := data.remove_item_at_slot(slot_index)
	if item:
		_auto_save()
	return item

func get_item_at_slot(slot_index: int) -> ItemData:
	return data.get_item_at_slot(slot_index)

func can_place_item(item_data: ItemData, slot_index: int) -> bool:
	return data.can_add_item(item_data, slot_index)

func get_items_in_area(slot_index: int, dimensions: Vector2i) -> Array[ItemData]:
	return data.get_items_in_area(slot_index, dimensions)

func save_inventory() -> void:
	if character_id.is_empty():
		return
	
	var saved_items := data.get_save_data()
	SavesManager.save_inventory(character_id, saved_items)
	inventory_saved.emit()

func load_inventory() -> void:
	if character_id.is_empty():
		return
	
	var character_data := SavesManager.load_character_data(character_id)
	if character_data and character_data.inventory_items.size() > 0:
		data.load_from_save_data(character_data.inventory_items)
		inventory_loaded.emit()

func _auto_save() -> void:
	if not character_id.is_empty():
		save_inventory()

func _on_item_added(item_data: ItemData, slot_index: int) -> void:
	item_added_to_inventory.emit(item_data, slot_index)

func _on_item_removed(item_data: ItemData, slot_index: int) -> void:
	item_removed_from_inventory.emit(item_data, slot_index)

func _on_inventory_changed() -> void:
	pass
