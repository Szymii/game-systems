class_name Item
extends Node2D

@onready var border_container: PanelContainer = %BorderContainer
@onready var item_label: Label = %ItemLabel

@export var item_data: ItemData

func _ready() -> void:
	if not item_data:
		push_error("Not item data for this item!!!")
		queue_free()
	
	item_label.text = item_data.name
	var rarity_color: Color = Rarity.get_rarity_color(item_data.rarity)
	item_label.self_modulate = rarity_color
	border_container.self_modulate = rarity_color

func _on_border_container_gui_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("interaction"):
		Global.try_pick_up_item(item_data, func() -> void: queue_free())
