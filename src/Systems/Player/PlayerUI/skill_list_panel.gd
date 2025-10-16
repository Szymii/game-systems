extends Panel

func _ready() -> void:
	visible = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("skill_list"):
		toggle_visibility()

func toggle_visibility() -> void:
	visible = !visible
