class_name InventoryItemView
extends Sprite2D

@onready var border_container: PanelContainer = %BorderContainer

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
	_update_border_container()

func set_item_data(_item_data: ItemData) -> void:
	item_data = _item_data
	if item_data:
		texture = item_data.texture
	_update_border_container()

func set_position_from_slot(pos: Vector2) -> void:
	global_position = pos + size / 2
	_update_border_container()

func update_visual_position(pos: Vector2) -> void:
	global_position = pos

func _update_border_container() -> void:
	if not border_container or not item_data:
		return
	
	var rarity_color: Color = Rarity.get_rarity_color(item_data.rarity)
	border_container.self_modulate = rarity_color

	var border_size := size - Vector2(2, 2)
	border_container.size = border_size
	border_container.position = - border_size / 2
