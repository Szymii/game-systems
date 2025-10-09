extends Control

@onready var start_btn: Button = %Start
@onready var exit_btn: Button = %Exit


func _ready() -> void:
	start_btn.pressed.connect(_on_start_pressed)
	exit_btn.pressed.connect(_on_exit_pressed)


func _on_start_pressed() -> void:
	print("start")


func _on_exit_pressed() -> void:
	get_tree().quit()
