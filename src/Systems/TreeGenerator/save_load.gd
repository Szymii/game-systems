extends Node

func _ready() -> void:
	TreeGeneratorGlobals.save_tree_signal.connect(_save_tree)
	TreeGeneratorGlobals.load_tree_signal.connect(_load_tree)

func _save_tree() -> void:
	print("saved")
	pass

func _load_tree() -> void:
	print("loaded")
	pass
