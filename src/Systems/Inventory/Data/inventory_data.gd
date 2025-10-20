class_name InventoryData
extends RefCounted

signal item_added(item_data: ItemData, slot_index: int)
signal item_removed(item_data: ItemData, slot_index: int)
signal inventory_changed()

const SLOT_SIZE: int = 32

var dimensions: Vector2i
var _slots: Array = []

func _init(_dimensions: Vector2i) -> void:
	dimensions = _dimensions
	_init_slots()

func can_add_item(item_data: ItemData, start_slot: int = -1) -> bool:
	var slot_index := start_slot if start_slot >= 0 else _find_free_slot(item_data.dimensions)
	if slot_index < 0:
		return false
	return _item_fits(slot_index, item_data.dimensions)

func add_item(item_data: ItemData, start_slot: int = -1) -> int:
	var slot_index := start_slot if start_slot >= 0 else _find_free_slot(item_data.dimensions)
	if slot_index < 0:
		return -1
	
	if not _item_fits(slot_index, item_data.dimensions):
		return -1
	
	_occupy_slots(slot_index, item_data)
	item_added.emit(item_data, slot_index)
	inventory_changed.emit()
	return slot_index

func remove_item_at_slot(slot_index: int) -> ItemData:
	if slot_index < 0 or slot_index >= _slots.size():
		return null
	
	var item_data: ItemData = _slots[slot_index]
	if not item_data:
		return null
	
	_free_slots(item_data)
	item_removed.emit(item_data, slot_index)
	inventory_changed.emit()
	return item_data

func get_item_at_slot(slot_index: int) -> ItemData:
	if slot_index < 0 or slot_index >= _slots.size():
		return null
	return _slots[slot_index]

func get_items_in_area(slot_index: int, item_dimensions: Vector2i) -> Array[ItemData]:
	var items: Dictionary = {}
	for y in item_dimensions.y:
		for x in item_dimensions.x:
			var curr_slot := slot_index + x + y * dimensions.x
			if curr_slot >= 0 and curr_slot < _slots.size():
				var item: ItemData = _slots[curr_slot]
				if item and not items.has(item):
					items[item] = true
	
	var result: Array[ItemData] = []
	result.assign(items.keys())
	return result

func get_save_data() -> Array[SavedInventoryItem]:
	var saved_items: Array[SavedInventoryItem] = []
	var processed_items: Dictionary = {}
	
	for i in _slots.size():
		var item: ItemData = _slots[i]
		if item and not processed_items.has(item):
			var saved_item := SavedInventoryItem.new()
			saved_item.item_data = item
			saved_item.slot_index = i
			saved_items.append(saved_item)
			processed_items[item] = true
	
	return saved_items

func load_from_save_data(saved_items: Array[SavedInventoryItem]) -> void:
	clear()
	for saved_item in saved_items:
		add_item(saved_item.item_data, saved_item.slot_index)

func clear() -> void:
	_slots.clear()
	_init_slots()
	inventory_changed.emit()

func get_slot_coords(slot_index: int, grid_global_pos: Vector2) -> Vector2i:
	@warning_ignore("integer_division")
	var row := slot_index / dimensions.x
	var column := slot_index % dimensions.x
	return Vector2i(grid_global_pos) + Vector2i(column * SLOT_SIZE, row * SLOT_SIZE)

func get_slot_from_coords(coords: Vector2, grid_global_pos: Vector2) -> int:
	var local_coords := Vector2i(coords) - Vector2i(grid_global_pos)
	@warning_ignore("integer_division")
	local_coords = local_coords / SLOT_SIZE
	var index := local_coords.x + local_coords.y * dimensions.x
	if index >= dimensions.x * dimensions.y or index < 0:
		return -1
	return index

func _init_slots() -> void:
	_slots.resize(dimensions.x * dimensions.y)
	_slots.fill(null)

func _find_free_slot(item_dimensions: Vector2i) -> int:
	for i in _slots.size():
		if _item_fits(i, item_dimensions):
			return i
	return -1

func _item_fits(index: int, item_dimensions: Vector2i) -> bool:
	for y in item_dimensions.y:
		for x in item_dimensions.x:
			var curr_index := index + x + y * dimensions.x
			if curr_index >= _slots.size():
				return false
			if _slots[curr_index] != null:
				return false
			@warning_ignore("integer_division")
			var split := index / dimensions.x != (index + x) / dimensions.x
			if split:
				return false
	return true

func _occupy_slots(index: int, item_data: ItemData) -> void:
	for y in item_data.dimensions.y:
		for x in item_data.dimensions.x:
			_slots[index + x + y * dimensions.x] = item_data

func _free_slots(item_data: ItemData) -> void:
	for i in _slots.size():
		if _slots[i] == item_data:
			_slots[i] = null

func _find_item_slot(item_data: ItemData) -> int:
	for i in _slots.size():
		if _slots[i] == item_data:
			return i
	return -1
