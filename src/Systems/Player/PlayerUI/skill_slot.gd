extends TextureRect

@onready var name_label: Label = %Label
@export var slot_name: String

func _ready() -> void:
	name_label.text = slot_name
