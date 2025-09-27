class_name Point
extends Node2D

@onready var sprite:Sprite2D = %Sprite2D
@onready var collision:CollisionShape2D = %CollisionShape2D
var size: PointSize.POINT_SIZE = PointSize.POINT_SIZE.SM

func _ready() -> void:
	set_point_size(size)

func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("interaction"):
		TreeGeneratorGlobals.select_point(self)
	if event.is_action_pressed("cancel_interaction"):
		queue_free()

func set_point_size(new_size: PointSize.POINT_SIZE) -> void:
	var shape: CircleShape2D = collision.shape
	size = new_size
	match size:
		PointSize.POINT_SIZE.SM:
			sprite.scale = Vector2(20, 20)
			shape.radius = 10
		PointSize.POINT_SIZE.MD:
			sprite.scale = Vector2(30, 30)
			shape.radius = 15
		PointSize.POINT_SIZE.LG:
			sprite.scale = Vector2(50, 50)
			shape.radius = 25


func get_point_size() -> PointSize.POINT_SIZE:
	return size
