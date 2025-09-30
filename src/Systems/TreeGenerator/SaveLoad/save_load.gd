extends Node

func _ready() -> void:
	TreeGeneratorGlobals.save_tree_signal.connect(_save_tree)
	TreeGeneratorGlobals.load_tree_signal.connect(_load_tree)

func _save_tree() -> void:
	var saved_data := SavedData.new()
	get_tree().call_group("SavableTreeElements", "on_tree_save", saved_data)
	ResourceSaver.save(saved_data, "user://saved_tree_template.tres")

func _load_tree() -> void:
	var saved_data := load("user://saved_tree_template.tres") as SavedData
	get_tree().call_group("SavableTreeElements", "on_tree_load", saved_data)
