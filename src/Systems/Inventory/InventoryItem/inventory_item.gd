class_name InventoryItemView
extends Sprite2D

var item_data: ItemData = null
var slot_index: int = -1

var size: Vector2:
	get():
		if item_data:
			return Vector2(item_data.dimensions.x, item_data.dimensions.y) * 32
		return Vector2.ZERO

var anchor_point: Vector2:
	get():
		return global_position - size / 2

func _ready() -> void:
	if item_data:
		texture = item_data.texture

func set_item_data(_item_data: ItemData) -> void:
	item_data = _item_data
	if item_data:
		texture = item_data.texture

func set_position_from_slot(pos: Vector2) -> void:
	global_position = pos + size / 2

func update_visual_position(pos: Vector2) -> void:
	global_position = pos
