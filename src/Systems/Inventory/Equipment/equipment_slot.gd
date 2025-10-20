class_name EquipmentSlot
extends ColorRect

@export var texture: Texture2D
@export var slot_type: EquipmentRules.SLOT_TYPE_ENUM = EquipmentRules.SLOT_TYPE_ENUM.WEAPON
@onready var color_rect: TextureRect = %ColorRect

func _ready() -> void:
	color_rect.texture = texture
