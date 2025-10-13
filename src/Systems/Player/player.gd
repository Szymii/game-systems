extends CharacterBody2D

@export var movement_speed: float = 230.0

@onready var sprite: Sprite2D = $Sprite2D

func _physics_process(_delta: float) -> void:
	velocity = PlayerMovement.handle_input(movement_speed)
	PlayerMovement.handle_direction_facing(sprite, get_global_mouse_position(), global_position)
	move_and_slide()
