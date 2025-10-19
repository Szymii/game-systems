class_name ItemGrid
extends GridContainer

const SLOT_SIZE: int = 32

@export var inventory_slot_scene: PackedScene
@export var dimensions: Vector2i

var slot_data: Array[InventoryItem] = []
var held_item_intersects: bool = false

func _ready() -> void:
	_create_slots()
	_init_slot_data()

func attempt_to_add_item_data(item: InventoryItem, on_success: Callable) -> bool:
	var slot_index: int = 0
	while slot_index < slot_data.size():
		if _item_fits(slot_index, item.data.dimensions):
			break
		slot_index += 1
	if slot_index >= slot_data.size():
		return false
	
	for y in item.data.dimensions.y:
		for x in item.data.dimensions.x:
			slot_data[slot_index + x + y * columns] = item
	
	on_success.call() # addChild
	item.set_init_position(_get_coords_from_slot_index(slot_index))
	return true

func get_save_data() -> Array[SavedInventoryItem]:
	var saved_items: Array[SavedInventoryItem] = []
	var processed_items: Dictionary = {}
	
	for i in slot_data.size():
		var item := slot_data[i]
		if item and not processed_items.has(item):
			var saved_item := SavedInventoryItem.new()
			saved_item.item_data = item.data
			saved_item.slot_index = i
			saved_items.append(saved_item)
			processed_items[item] = true
	
	return saved_items

func load_from_save_data(saved_items: Array[SavedInventoryItem], inventory_item_scene: PackedScene, parent_node: Node) -> void:
	for saved_item in saved_items:
		var inventory_item: InventoryItem = inventory_item_scene.instantiate()
		inventory_item.data = saved_item.item_data
		_add_item_to_slot_data(saved_item.slot_index, inventory_item)
		parent_node.add_child(inventory_item)
		inventory_item.set_init_position(_get_coords_from_slot_index(saved_item.slot_index))


func _create_slots() -> void:
	self.columns = dimensions.x
	for y in dimensions.y:
		for x in dimensions.x:
			var inventory_slot := inventory_slot_scene.instantiate()
			add_child(inventory_slot)

func _gui_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("interaction"):
		var held_item := get_tree().get_first_node_in_group("held_item") as InventoryItem
		if !held_item:
			var slot_index := _get_slot_index_from_coords(get_global_mouse_position())
			var item := slot_data[slot_index]
			if !item:
				return
			item.get_picked_up()
			_remove_item_from_slot_data(item)
		else:
			if !held_item_intersects: return
			var offset := Vector2(SLOT_SIZE, SLOT_SIZE) / 2
			var index := _get_slot_index_from_coords(held_item.anchor_point + offset)
			var items := _items_in_area(index, held_item.data.dimensions)
			if items.size():
				if items.size() == 1:
					@warning_ignore("unsafe_cast")
					var item_to_swap := items[0] as InventoryItem
					if item_to_swap:
						held_item.get_placed(_get_coords_from_slot_index(index))
						_remove_item_from_slot_data(item_to_swap)
						_add_item_to_slot_data(index, held_item)
						item_to_swap.get_picked_up()
				return
			held_item.get_placed(_get_coords_from_slot_index(index))
			_add_item_to_slot_data(index, held_item)
	if event is InputEventMouseMotion:
		var held_item_node: InventoryItem = get_tree().get_first_node_in_group("held_item") as InventoryItem
		if held_item_node:
			_detect_held_item_intersection(held_item_node)

func _detect_held_item_intersection(held_item: InventoryItem) -> void:
	var h_rect := Rect2(held_item.anchor_point, held_item.size)
	var g_rect := Rect2(global_position, size)
	var inter := h_rect.intersection(g_rect).size
	held_item_intersects = (inter.x * inter.y) / (held_item.size.x * held_item.size.y) > 0.8

func _remove_item_from_slot_data(item: InventoryItem) -> void:
	for i in slot_data.size():
		if slot_data[i] == item:
			slot_data[i] = null

func _add_item_to_slot_data(index: int, item: InventoryItem) -> void:
	for y in item.data.dimensions.y:
		for x in item.data.dimensions.x:
			slot_data[index + x + y * columns] = item

func _items_in_area(index: int, item_dimensions: Vector2i) -> Array:
	var items: Dictionary = {}
	for y in item_dimensions.y:
		for x in item_dimensions.x:
			var slot_index := index + x + y * columns
			var item := slot_data[slot_index]
			if !item:
				continue
			if !items.has(item):
				items[item] = true
	return items.keys() if items.size() else []

func _init_slot_data() -> void:
	slot_data.resize(dimensions.x * dimensions.y)
	slot_data.fill(null)

func _item_fits(index: int, item_dimensions: Vector2i) -> bool:
	for y in item_dimensions.y:
		for x in item_dimensions.x:
			var curr_index := index + x + y * columns
			if curr_index >= slot_data.size():
				return false
			if slot_data[curr_index] != null:
				return false
			@warning_ignore("integer_division")
			var split := index / columns != (index + x) / columns
			if split:
				return false
	return true

func _get_slot_index_from_coords(coords: Vector2i) -> int:
	coords -= Vector2i(self.global_position)
	coords = coords / SLOT_SIZE
	var index := coords.x + coords.y * columns
	if index > dimensions.x * dimensions.y || index < 0:
		return -1
	return index

func _get_coords_from_slot_index(index: int) -> Vector2i:
	@warning_ignore("integer_division")
	var row := index / columns
	var column := index % columns
	return Vector2i(global_position) + Vector2i(column * SLOT_SIZE, row * SLOT_SIZE)
